--渾然たる闘牛詩－オルフェブル
-- 效果：
-- 这张卡不能通常召唤。把这张卡以外的光·暗属性怪兽各2只从自己的手卡·墓地除外的场合才能特殊召唤。
-- ①：这个方法特殊召唤的这张卡的攻击力上升因为那次特殊召唤而从手卡除外的怪兽数量×1000，同1次的战斗阶段中可以向怪兽作出最多有为那次特殊召唤而从墓地除外的怪兽数量的攻击。
-- ②：这张卡战斗破坏对方怪兽的伤害计算后才能发动。那只对方怪兽除外。
local s,id,o=GetID()
-- 初始化效果：注册召唤限制、特殊召唤规则、战斗破坏怪兽时除外的诱发效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 把这张卡以外的光·暗属性怪兽各2只从自己的手卡·墓地除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽的伤害计算后才能发动。那只对方怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 创建条件检查数组，用于验证除外的怪兽是否满足“2只光属性和2只暗属性”
s.spchecks=aux.CreateChecks(Card.IsAttribute,{ATTRIBUTE_LIGHT,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK,ATTRIBUTE_DARK})
-- 过滤手卡·墓地中可以作为特殊召唤Cost除外的光·暗属性怪兽
function s.spcostfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件判断：检查怪兽区域是否有空位，以及手卡·墓地中是否存在满足除外条件的怪兽组合
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断自己场上是否有可用的怪兽区域
	if Duel.GetMZoneCount(tp)<=0 then return false end
	-- 获取手卡和墓地中所有可作为Cost除外的光·暗属性怪兽
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,c)
	return g:CheckSubGroupEach(s.spchecks)
end
-- 特殊召唤规则的准备操作：让玩家选择满足条件的4只怪兽，并将其暂存
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡和墓地中所有可作为Cost除外的光·暗属性怪兽
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,c)
	-- 发送提示信息，要求玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroupEach(tp,s.spchecks,true)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作：除外选定的怪兽，并根据从手卡/墓地除外的怪兽数量，对特殊召唤的这张卡适用攻击力上升、追加攻击或无法攻击的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	local gatk=g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
	local matk=g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	-- 将选定的怪兽除外，作为特殊召唤的Cost
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
	if gatk>0 then
		-- 这个方法特殊召唤的这张卡的攻击力上升因为那次特殊召唤而从手卡除外的怪兽数量×1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(gatk*1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	if matk>1 then
		-- 同1次的战斗阶段中可以向怪兽作出最多有为那次特殊召唤而从墓地除外的怪兽数量的攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e2:SetValue(matk-1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
		c:RegisterEffect(e2)
	end
	if matk==0 then
		-- 同1次的战斗阶段中可以向怪兽作出最多有为那次特殊召唤而从墓地除外的怪兽数量的攻击。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
		c:RegisterEffect(e3)
	end
end
-- 效果②的发动条件判断：伤害计算后，这张卡战斗破坏了对方怪兽并确认其已被破坏
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsStatus(STATUS_OPPO_BATTLE) and bc:IsControler(1-tp)
end
-- 效果②的靶向处理：检查被破坏的对方怪兽是否可以除外，并设置除外的操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc:IsAbleToRemove() end
	-- 设置连锁处理中的操作信息：将1张被战斗破坏的对方怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
end
-- 效果②的效果处理：将被战斗破坏的对方怪兽除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		-- 将该对方怪兽除外
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
