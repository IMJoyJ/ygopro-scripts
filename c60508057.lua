--RR－ナパーム・ドラゴニアス
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。给与对方600伤害。这个效果的发动后，直到回合结束时自己不能把「急袭猛禽」怪兽以外的怪兽的效果发动。
-- ②：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只「急袭猛禽」怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c60508057.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。给与对方600伤害。这个效果的发动后，直到回合结束时自己不能把「急袭猛禽」怪兽以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60508057,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c60508057.damtg)
	e1:SetOperation(c60508057.damop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只「急袭猛禽」怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60508057,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c60508057.spcon)
	e2:SetTarget(c60508057.sptg)
	e2:SetOperation(c60508057.spop)
	c:RegisterEffect(e2)
end
-- 效果①的Target函数：设置伤害目标与伤害数值，并声明操作信息
function c60508057.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数（伤害数值）为600
	Duel.SetTargetParam(600)
	-- 设置当前连锁的操作信息为：给与对方玩家600点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 效果①的Operation函数：给与对方伤害，并注册本回合不能发动「急袭猛禽」以外怪兽效果的限制
function c60508057.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家和对象参数（伤害数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
	-- 这个效果的发动后，直到回合结束时自己不能把「急袭猛禽」怪兽以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c60508057.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制效果注册给发动效果的玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的过滤条件：不能发动「急袭猛禽」怪兽以外的怪兽的效果
function c60508057.actlimit(e,re,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not rc:IsSetCard(0xba)
end
-- 效果②的发动条件：这张卡被战斗破坏送去墓地
function c60508057.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 效果②的特殊召唤怪兽过滤：卡组中可以特殊召唤的「急袭猛禽」怪兽
function c60508057.spfilter(c,e,tp)
	return c:IsSetCard(0xba) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的Target函数：检查怪兽区域空位以及卡组中是否存在可特殊召唤的「急袭猛禽」怪兽，并声明操作信息
function c60508057.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组中是否存在至少1只满足条件的「急袭猛禽」怪兽
		and Duel.IsExistingMatchingCard(c60508057.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的Operation函数：从卡组特殊召唤1只「急袭猛禽」怪兽，并将其效果无效化
function c60508057.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足条件的「急袭猛禽」怪兽
	local g=Duel.SelectMatchingCard(tp,c60508057.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 如果成功选择怪兽，则尝试将其以表侧表示特殊召唤（分解步骤）
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
