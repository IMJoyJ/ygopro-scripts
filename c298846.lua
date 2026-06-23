--トリックスター・コルチカ
-- 效果：
-- 连接怪兽以外的「淘气仙星」怪兽1只
-- 自己对「淘气仙星·科尔奇卡」1回合只能有1次特殊召唤，那个效果1回合只能使用1次。
-- ①：这张卡在墓地存在的状态，自己的「淘气仙星」怪兽的战斗让怪兽被破坏时，把这张卡除外，以那1只破坏的怪兽为对象才能发动。给与对方那只怪兽的攻击力数值的伤害。
local s,id,o=GetID()
-- 注册卡片效果，设置一回合只能特殊召唤1次，添加连接召唤手续，启用苏生限制，创建诱发效果
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	-- 添加连接召唤手续，使用满足条件的怪兽作为连接素材
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
	-- 设置效果发动的费用为将此卡除外
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
-- 连接怪兽以外的「淘气仙星」怪兽1只
function s.mat(c)
	return c:IsLinkSetCard(0xfb) and not c:IsLinkType(TYPE_LINK)
end
-- 筛选满足条件的被破坏怪兽，判断是否为「淘气仙星」怪兽且在战斗中被破坏
function s.damfilter(c,tp,e)
	if c:IsSetCard(0xfb) and c:IsPreviousControler(tp) then return true end
	local rc=c:GetBattleTarget()
	return rc:IsSetCard(0xfb)
		and (not rc:IsLocation(LOCATION_MZONE) and rc:IsPreviousControler(tp)
			or rc:IsLocation(LOCATION_MZONE) and rc:IsControler(tp))
end
-- 判断是否满足发动条件，即是否有「淘气仙星」怪兽被战斗破坏且不在连锁中
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.damfilter,1,nil,tp,e)
end
-- 筛选满足条件的目标怪兽，必须为表侧表示、攻击力大于0、非衍生物、可成为效果对象
function s.tgfilter(c,e)
	return not c:IsType(TYPE_TOKEN) and c:IsFaceupEx() and c:GetBaseAttack()>0 and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e)
end
-- 设置效果目标，选择一个满足条件的怪兽作为目标，并设置伤害值
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=eg:Filter(s.tgfilter,nil,e)
	if chk==0 then return g:GetCount()>0 end
	local bc=g:GetFirst()
	if g:GetCount()>1 then
		bc=g:FilterSelect(tp,s.tgfilter,1,1,nil,e):GetFirst()
	end
	-- 将目标怪兽设置为当前连锁处理的对象
	Duel.SetTargetCard(bc)
	local dam=bc:GetBaseAttack()
	-- 设置操作信息，指定将对对方造成目标怪兽攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 执行效果操作，对对方造成目标怪兽攻击力数值的伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以目标怪兽的攻击力为基准，对对方造成相应数值的伤害
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
