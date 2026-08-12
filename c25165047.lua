--ライフ・ストリーム・ドラゴン
-- 效果：
-- 调整＋「动力工具龙」
-- ①：这张卡同调召唤成功时才能发动。自己基本分变成4000。
-- ②：只要这张卡在怪兽区域存在，自己受到的效果伤害变成0。
-- ③：这张卡被破坏的场合，可以作为代替把自己墓地1张装备魔法卡除外。
function c25165047.initial_effect(c)
	-- 为该怪兽添加允许使用的素材代码列表，指定只能使用代码为2403771的卡作为素材
	aux.AddMaterialCodeList(c,2403771)
	-- 添加同调召唤手续，要求必须使用1只调整和1只代码为2403771的卡作为素材
	aux.AddSynchroProcedure(c,nil,aux.FilterBoolFunction(Card.IsCode,2403771),1,1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功时才能发动。自己基本分变成4000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25165047,0))  --"自己基本分变成4000"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c25165047.lpcon)
	e1:SetOperation(c25165047.lpop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己受到的效果伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(c25165047.damval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e3)
	-- ③：这张卡被破坏的场合，可以作为代替把自己墓地1张装备魔法卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(c25165047.desreptg)
	c:RegisterEffect(e4)
	-- 当此卡被同调召唤时，若其素材中包含调整，则获得效果21142671（此效果为特殊效果，仅在特定条件下生效）
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_MATERIAL_CHECK)
	e5:SetValue(c25165047.valcheck)
	c:RegisterEffect(e5)
end
c25165047.material_type=TYPE_SYNCHRO
-- 判断此卡是否为同调召唤 summoned
function c25165047.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 将玩家的LP设置为4000
function c25165047.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 将玩家的LP设置为4000
	Duel.SetLP(tp,4000)
end
-- 当受到效果伤害时，若伤害原因为效果，则将伤害值设为0
function c25165047.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0 end
	return val
end
-- 过滤函数，用于判断目标卡是否为装备魔法且可作为除外费用
function c25165047.repfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToRemoveAsCost()
end
-- 判断此卡是否因效果或战斗破坏且未被代替破坏，同时确认玩家墓地是否存在满足条件的装备魔法卡
function c25165047.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
		-- 确认玩家墓地是否存在满足条件的装备魔法卡
		and Duel.IsExistingMatchingCard(c25165047.repfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 询问玩家是否发动此效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择满足条件的1张装备魔法卡
		local g=Duel.SelectMatchingCard(tp,c25165047.repfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选中的装备魔法卡除外（作为费用）
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		return true
	else return false end
end
-- 检查此卡的素材中是否包含调整类型，若包含则赋予其特殊效果21142671
function c25165047.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,2,nil,TYPE_TUNER) then
		-- 赋予此卡特殊效果21142671，该效果在回合结束时重置
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(21142671)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
