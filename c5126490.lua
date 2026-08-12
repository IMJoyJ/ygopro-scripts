--ネオス・ワイズマン
-- 效果：
-- 这张卡不能通常召唤。把自己的怪兽区域的表侧表示的「元素英雄 新宇侠」和「于贝尔」各1只送去墓地的场合才能特殊召唤。
-- ①：场上的这张卡不会被效果破坏。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时发动。给与对方那只对方怪兽的攻击力数值的伤害。自己基本分回复那只对方怪兽的守备力的数值。
function c5126490.initial_effect(c)
	-- 注册该卡牌效果中涉及的其他卡片编号，用于识别特殊召唤条件所需的「元素英雄 新宇侠」和「于贝尔」
	aux.AddCodeList(c,89943723,78371393)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己的怪兽区域的表侧表示的「元素英雄 新宇侠」和「于贝尔」各1只送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 特殊召唤时需要满足条件：从自己场上选择1组符合条件的「元素英雄 新宇侠」和「于贝尔」各1只，将其送去墓地作为特殊召唤的条件。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c5126490.spcon)
	e2:SetTarget(c5126490.sptg)
	e2:SetOperation(c5126490.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时发动。给与对方那只对方怪兽的攻击力数值的伤害。自己基本分回复那只对方怪兽的守备力的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(5126490,0))  --"回复&伤害"
	e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	-- 效果发动条件为该卡参与了战斗且战斗阶段已结束，确保效果只在实际战斗后触发。
	e3:SetCondition(aux.dsercon)
	e3:SetTarget(c5126490.damtg)
	e3:SetOperation(c5126490.damop)
	c:RegisterEffect(e3)
	-- ①：场上的这张卡不会被效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 用于筛选场上可以送去墓地的表侧表示怪兽的过滤函数
function c5126490.spfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 用于判断所选的2张怪兽是否分别满足「元素英雄 新宇侠」和「于贝尔」的条件
function c5126490.fselect(g,tp)
	-- 检查所选的2张怪兽是否分别满足「元素英雄 新宇侠」和「于贝尔」的条件
	return aux.mzctcheck(g,tp) and aux.gfcheck(g,Card.IsCode,89943723,78371393)
end
-- 判断特殊召唤时是否满足条件：场上存在符合条件的2只怪兽（分别为「元素英雄 新宇侠」和「于贝尔」）
function c5126490.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家场上所有可以送去墓地的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c5126490.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c5126490.fselect,2,2,tp)
end
-- 选择满足条件的2张怪兽并将其标记为特殊召唤时要送去墓地的卡片组
function c5126490.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上所有可以送去墓地的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c5126490.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c5126490.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤前将选中的2张怪兽送去墓地
function c5126490.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的卡片组以特殊召唤原因送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 设置效果发动时的目标信息，包括造成伤害和回复LP的数量
function c5126490.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return c:IsStatus(STATUS_OPPO_BATTLE) and bc~=nil end
	-- 设置要对对方造成伤害的数值为对方怪兽的攻击力
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetAttack())
	-- 设置要对自己回复LP的数值为对方怪兽的守备力
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,bc:GetDefense())
end
-- 执行效果：给与对方伤害并回复自己LP
function c5126490.damop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	local atk=bc:GetAttack()
	local def=bc:GetDefense()
	if atk<0 then atk=0 end
	if def<0 then def=0 end
	-- 给与对方指定数值的伤害，伤害来源为该卡的战斗
	Duel.Damage(1-tp,atk,REASON_EFFECT,true)
	-- 使自己回复指定数值的LP，回复来源为该卡的战斗
	Duel.Recover(tp,def,REASON_EFFECT,true)
	-- 完成伤害/回复LP过程的时点处理
	Duel.RDComplete()
end
