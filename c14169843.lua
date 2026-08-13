--アロマージ－ローリエ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己基本分比对方多的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己基本分回复的场合，以场上1只植物族怪兽为对象发动。这个回合，那只怪兽当作调整使用。
-- ③：这张卡被送去墓地的场合才能发动。自己回复500基本分。
function c14169843.initial_effect(c)
	-- ①：自己基本分比对方多的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14169843,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,14169843)
	e1:SetCondition(c14169843.spcon)
	e1:SetTarget(c14169843.sptg)
	e1:SetOperation(c14169843.spop)
	c:RegisterEffect(e1)
	-- ②：自己基本分回复的场合，以场上1只植物族怪兽为对象发动。这个回合，那只怪兽当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14169843,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_RECOVER)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,14169844)
	e2:SetCondition(c14169843.tncon)
	e2:SetTarget(c14169843.tntg)
	e2:SetOperation(c14169843.tnop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合才能发动。自己回复500基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(14169843,2))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,14169845)
	e3:SetTarget(c14169843.rectg)
	e3:SetOperation(c14169843.recop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判定：比较自己与对方的基本分。
function c14169843.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回自己LP是否大于对方LP的判定结果，作为①效果的发动条件。
	return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
-- 效果①的发动时合法性检查：确认自己场上空位足够且这张卡可以特殊召唤。
function c14169843.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记连锁的操作信息：本次效果涉及特殊召唤这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①处理函数：若这张卡仍与效果关联，则将其特殊召唤。
function c14169843.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到tp玩家场上（正常检查召唤条件与苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的触发条件判定：回复基本分的玩家是这张卡的控制者（自己）。
function c14169843.tncon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 对象过滤条件：表侧表示的植物族怪兽，且不是调整怪兽。
function c14169843.tnfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and not c:IsType(TYPE_TUNER)
end
-- 效果②取对象：从双方场上选择1只表侧表示的植物族怪兽作为对象；连锁回放时检查所选卡是否仍合法。
function c14169843.tntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c14169843.tnfilter(chkc) end
	if chk==0 then return true end
	-- 发送选择提示，提示玩家选择一张表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从双方主要怪兽区选择1只符合条件的植物族怪兽，并登记为连锁对象。
	Duel.SelectTarget(tp,c14169843.tnfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果②处理：若对象仍与效果关联且表侧表示，则给它赋予‘调整’类型直到回合结束（该赋予效果不能被无效）。
function c14169843.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果②选定的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只怪兽当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
end
-- 效果③的目标处理：设定回复玩家为自己、回复量为500，并登记回复操作；无其他选择对象，chk==0时直接通过。
function c14169843.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把本次回复的受益玩家设为自己。
	Duel.SetTargetPlayer(tp)
	-- 设定回复数值参数为500。
	Duel.SetTargetParam(500)
	-- 登记连锁操作信息：本效果将为自己回复500LP，效果类别为回复。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 效果③处理函数：根据已登记的目标玩家和数值执行LP回复。
function c14169843.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家p和回复参数d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果为原因让玩家p回复d点基本分（即自己回复500LP）。
	Duel.Recover(p,d,REASON_EFFECT)
end
