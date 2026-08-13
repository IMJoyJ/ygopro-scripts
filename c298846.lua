--トリックスター・コルチカ
-- 效果：
-- 连接怪兽以外的「淘气仙星」怪兽1只
-- 自己对「淘气仙星·科尔奇卡」1回合只能有1次特殊召唤，那个效果1回合只能使用1次。
-- ①：这张卡在墓地存在的状态，自己的「淘气仙星」怪兽的战斗让怪兽被破坏时，把这张卡除外，以那1只破坏的怪兽为对象才能发动。给与对方那只怪兽的攻击力数值的伤害。
local s,id,o=GetID()
-- 初始化该卡的效果：设置同名卡1回合1次的特殊召唤限制，添加连接召唤手续，加上苏生限制，并注册①效果：在墓地作为诱发选发效果，以战斗破坏事件为触发，取对象，并支付除外自身的cost，给予伤害。
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	-- 添加连接召唤手续：使用1只满足s.mat过滤条件的怪兽作为连接素材进行连接召唤。
	aux.AddLinkProcedure(c,s.mat,1,1)
	c:EnableReviveLimit()
	-- ①：这张卡在墓地存在的状态，自己的「淘气仙星」怪兽的战斗让怪兽被破坏时，把这张卡除外，以那1只破坏的怪兽为对象才能发动。给与对方那只怪兽的攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"伤害效果"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.damcon)
	-- 设置发动代价：将墓地中的这张卡除外作为发动代价。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
-- 连接素材筛选函数：作为连接素材的怪兽必须是卡名含有「淘气仙星」字段、且不是连接怪兽的怪兽。
function s.mat(c)
	return c:IsLinkSetCard(0xfb) and not c:IsLinkType(TYPE_LINK)
end
-- damfilter筛选函数：用于判断被战斗破坏的怪兽是否满足触发条件——被破坏的怪兽本身是破坏前自己场上的「淘气仙星」怪兽，或者其战斗对象是自己场上的「淘气仙星」怪兽（根据战斗对象是否仍在场上，通过当前控制者或之前控制者判断）。
function s.damfilter(c,tp,e)
	if c:IsSetCard(0xfb) and c:IsPreviousControler(tp) then return true end
	local rc=c:GetBattleTarget()
	return rc:IsSetCard(0xfb)
		and (not rc:IsLocation(LOCATION_MZONE) and rc:IsPreviousControler(tp)
			or rc:IsLocation(LOCATION_MZONE) and rc:IsControler(tp))
end
-- damcon发动条件：被战斗破坏的怪兽集合中不包含这张卡自身，且存在至少1只满足s.damfilter条件的怪兽，即发生了自己的「淘气仙星」怪兽参与战斗导致怪兽被破坏的事件。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.damfilter,1,nil,tp,e)
end
-- tgfilter对象筛选：对象必须不是衍生物、是表侧表示怪兽、原本攻击力大于0，且能够成为效果对象。
function s.tgfilter(c,e)
	return not c:IsType(TYPE_TOKEN) and c:IsFaceupEx() and c:GetBaseAttack()>0 and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e)
end
-- damtg目标处理：从被破坏的怪兽中筛选出满足tgfilter的卡；若存在，则选择其中1只（若有多个则由玩家选择）作为对象，并设置给对方造成该对象原本攻击力数值的伤害的操作信息。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=eg:Filter(s.tgfilter,nil,e)
	if chk==0 then return g:GetCount()>0 end
	local bc=g:GetFirst()
	if g:GetCount()>1 then
		bc=g:FilterSelect(tp,s.tgfilter,1,1,nil,e):GetFirst()
	end
	-- 将选择的那只被破坏怪兽设置为当前连锁效果的对象。
	Duel.SetTargetCard(bc)
	local dam=bc:GetBaseAttack()
	-- 设置连锁操作信息：本效果将造成伤害，对象为对方玩家，伤害数值为所选怪兽的原本攻击力。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- damop效果处理：取回效果对象，若该对象仍与效果关联，则给对方造成其原本攻击力数值的效果伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 给予对方玩家对象怪兽原本攻击力数值的伤害，伤害原因是效果。
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
