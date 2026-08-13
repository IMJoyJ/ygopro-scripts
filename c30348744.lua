--TG ドリル・フィッシュ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上的怪兽只有「科技属」怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡可以直接攻击。
-- ③：自己的「科技属」怪兽给与对方战斗伤害时，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
function c30348744.initial_effect(c)
	-- ②：这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- 这个卡名的①③的效果1回合各能使用1次。①：自己场上的怪兽只有「科技属」怪兽的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,30348744)
	e2:SetCondition(c30348744.spcon)
	e2:SetTarget(c30348744.sptg)
	e2:SetOperation(c30348744.spop)
	c:RegisterEffect(e2)
	-- 这个卡名的①③的效果1回合各能使用1次。③：自己的「科技属」怪兽给与对方战斗伤害时，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,30348745)
	e3:SetCondition(c30348744.descon)
	e3:SetTarget(c30348744.destg)
	e3:SetOperation(c30348744.desop)
	c:RegisterEffect(e3)
end
-- 判定怪兽是否为“不符合条件”：里侧表示或不属于「科技属」的怪兽会令条件失败，用于确认场上怪兽“只有「科技属」怪兽”。
function c30348744.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x27)
end
-- 特招效果的发动条件：己方怪兽区存在至少1只怪兽，且所有怪兽均为表侧表示并属于「科技属」，不存在里侧或非「科技属」怪兽。
function c30348744.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得己方主要怪兽区的全部怪兽。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return g:GetCount()>0 and not g:IsExists(c30348744.cfilter,1,nil)
end
-- 特招效果的目标函数：在发动时检查己方主怪兽区是否有空位，以及此卡是否可以被特殊召唤。
function c30348744.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记连锁操作信息：本次效果处理将特殊召唤此卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特招效果处理：若此卡仍与本次效果关联，则将其表侧表示特殊召唤到己方场上。
function c30348744.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡表侧表示特殊召唤到己方主要怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 破坏效果的发动条件：己方「科技属」怪兽给予了对方战斗伤害，即事件中受伤害方为对方，造成伤害的怪兽控制者为己方且属于「科技属」。
function c30348744.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:IsControler(tp) and tc:IsSetCard(0x27)
end
-- 破坏效果的目标处理：在对方场上选择1只怪兽作为对象，并完成选择提示、目标登记和操作信息登记。
function c30348744.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 发动时确认：对方场上有1只可被选为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示消息，提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象，同时将该卡登记为本次连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记连锁操作信息：本次效果处理将破坏所选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果处理：若对象怪兽仍与本次效果关联，则将其破坏。
function c30348744.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次连锁中登记的第一张对象卡（即选择的那只对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将该对象怪兽破坏并送去墓地。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
