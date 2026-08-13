--ライフ・ストリーム・ドラゴン
-- 效果：
-- 调整＋「动力工具龙」
-- ①：这张卡同调召唤成功时才能发动。自己基本分变成4000。
-- ②：只要这张卡在怪兽区域存在，自己受到的效果伤害变成0。
-- ③：这张卡被破坏的场合，可以作为代替把自己墓地1张装备魔法卡除外。
function c25165047.initial_effect(c)
	-- 将卡号2403771（动力工具龙）加入素材代码列表，用于同调召唤手续中识别该卡为允许的素材。
	aux.AddMaterialCodeList(c,2403771)
	-- 添加同调召唤手续：需要1只任意调整怪兽加上1只动力工具龙作为素材（非调整素材数量为1），对应『调整＋「动力工具龙」』。
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
	-- 调整＋「动力工具龙」
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_MATERIAL_CHECK)
	e5:SetValue(c25165047.valcheck)
	c:RegisterEffect(e5)
end
c25165047.material_type=TYPE_SYNCHRO
-- 判定效果触发条件：这张卡是用同调召唤方式特殊召唤成功的，作为①效果可发动的条件。
function c25165047.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果处理：将发动玩家的基本分直接设置为4000。
function c25165047.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 将玩家tp的基本分改为4000。
	Duel.SetLP(tp,4000)
end
-- 伤害计算函数：当伤害来源为效果伤害时，将伤害数值改为0，实现『自己受到的效果伤害变成0』。
function c25165047.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0 end
	return val
end
-- 过滤条件：选择墓地中一张装备魔法卡，且该卡可以作为被除外的代价（满足除外代价条件）。
function c25165047.repfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToRemoveAsCost()
end
-- 代替破坏的判定条件：当此卡因战斗或效果将要被破坏，且不是由代替破坏导致时，检查墓地是否有可除外的装备魔法卡，以决定能否发动代替破坏。
function c25165047.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
		-- 进一步检查自己墓地是否存在至少1张满足repfilter的装备魔法卡，作为发动代替破坏的前提。
		and Duel.IsExistingMatchingCard(c25165047.repfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出‘是/否’选择框，询问玩家是否发动代替破坏效果（除外墓地装备魔法卡代替本次破坏）。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 发送选择提示信息，提示玩家即将选择要除外的卡片，提示文字为‘请选择要除外的卡’。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从自己墓地选择1张满足repfilter条件的装备魔法卡，作为代替破坏的代偿卡。
		local g=Duel.SelectMatchingCard(tp,c25165047.repfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选中的装备魔法卡以表侧表示除外，除外原因为COST（代价），从而完成代替破坏。
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		return true
	else return false end
end
-- 素材检查处理：当此卡被作为同调素材时，检查同调素材中是否有至少2只调整怪兽；若有，则给此卡注册一个不可无效、不可复制的效果，并设置其在回合结束时重置。
function c25165047.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,2,nil,TYPE_TUNER) then
		-- 调整
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(21142671)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
