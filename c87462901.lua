--幻蝋館の使者
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ③：对方战斗阶段结束时才能发动。对方场上的全部攻击表示怪兽直到下次的对方战斗阶段开始时不能把表示形式变更，不能作为融合·同调·超量·连接召唤的素材，效果无效化。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特召，②战斗不破，③对方战阶结束时对方场上攻击表示怪兽不能变表示形式、不能作为素材且效果无效。
function s.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：对方战斗阶段结束时才能发动。对方场上的全部攻击表示怪兽直到下次的对方战斗阶段开始时不能把表示形式变更，不能作为融合·同调·超量·连接召唤的素材，效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：对方怪兽进行攻击宣言时。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前攻击宣言的怪兽是否由对方控制。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 效果①的发动准备：检查怪兽区域是否有空位，以及自身是否能特殊召唤，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示此效果会特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将自身从手卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的适用对象过滤：自身以及与自身进行战斗的对方怪兽。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 效果③的发动条件：对方的回合。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方。
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤条件：处于攻击表示的怪兽。
function s.filter(c)
	return c:IsPosition(POS_ATTACK)
end
-- 效果③的发动准备：检查对方场上是否存在攻击表示的怪兽。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只攻击表示的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果③的效果处理：使对方场上所有攻击表示怪兽直到下次对方战斗阶段开始时不能变更表示形式、不能作为融合/同调/超量/连接素材，且效果无效化。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有的攻击表示怪兽。
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		local tc=g:GetFirst()
		while tc do
			-- 不能把表示形式变更
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE_START+RESET_OPPO_TURN)
			e1:SetTargetRange(0,LOCATION_MZONE)
			tc:RegisterEffect(e1)
			-- 不能作为融合·同调·超量·连接召唤的素材
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			e2:SetRange(LOCATION_MZONE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE_START+RESET_OPPO_TURN)
			e2:SetValue(1)
			tc:RegisterEffect(e2)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
			e3:SetValue(s.fuslimit)
			tc:RegisterEffect(e3)
			local e4=e2:Clone()
			e4:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
			tc:RegisterEffect(e4)
			local e5=e2:Clone()
			e5:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			tc:RegisterEffect(e5)
			tc=g:GetNext()
		end
		-- 从获取的怪兽中筛选出未被无效化的效果怪兽。
		local sg=g:Filter(aux.NegateEffectMonsterFilter,nil)
		local sc=sg:GetFirst()
		while sc do
			-- 无效化与目标怪兽相关的连锁。
			Duel.NegateRelatedChain(sc,RESET_TURN_SET)
			-- 效果无效化
			local e6=Effect.CreateEffect(c)
			e6:SetType(EFFECT_TYPE_SINGLE)
			e6:SetCode(EFFECT_DISABLE)
			e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e6:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE_START+RESET_OPPO_TURN)
			sc:RegisterEffect(e6)
			-- 效果无效化
			local e7=Effect.CreateEffect(c)
			e7:SetType(EFFECT_TYPE_SINGLE)
			e7:SetCode(EFFECT_DISABLE_EFFECT)
			e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e7:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE_START+RESET_OPPO_TURN)
			e7:SetValue(RESET_TURN_SET)
			sc:RegisterEffect(e7)
			sc=sg:GetNext()
		end
	end
end
-- 限制不能作为融合召唤的素材。
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
