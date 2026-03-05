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
-- 判断发动条件：自己基本分是否比对方多
function c14169843.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回判断结果：自己基本分大于对方基本分
	return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
-- 设置特殊召唤的发动条件
function c14169843.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤的条件：场上是否有空位且此卡可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤的操作
function c14169843.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断发动条件：是否为自己的回复事件
function c14169843.tncon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 筛选目标：场上正面表示的植物族非调整怪兽
function c14169843.tnfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and not c:IsType(TYPE_TUNER)
end
-- 设置调整效果的发动条件
function c14169843.tntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c14169843.tnfilter(chkc) end
	if chk==0 then return true end
	-- 提示选择目标：选择一个正面表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择目标：选择一个正面表示的植物族怪兽
	Duel.SelectTarget(tp,c14169843.tnfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 执行调整效果的操作
function c14169843.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 给目标怪兽添加调整属性
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
end
-- 设置回复效果的发动条件
function c14169843.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：指定回复玩家
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息：指定回复数值
	Duel.SetTargetParam(500)
	-- 设置操作信息：将回复效果加入连锁
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 执行回复效果的操作
function c14169843.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和目标数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数值的LP
	Duel.Recover(p,d,REASON_EFFECT)
end
