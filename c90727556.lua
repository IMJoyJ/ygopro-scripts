--インヴェルズの斥候
-- 效果：
-- 自己场上没有魔法·陷阱卡存在的场合，自己的主要阶段1的开始时才能发动。墓地存在的这张卡在自己场上特殊召唤。这个效果发动的回合，自己不能把怪兽特殊召唤。这张卡不能为名字带有「侵入魔鬼」的怪兽的上级召唤以外而解放，也不能作为同调素材。
function c90727556.initial_effect(c)
	-- 自己场上没有魔法·陷阱卡存在的场合，自己的主要阶段1的开始时才能发动。墓地存在的这张卡在自己场上特殊召唤。这个效果发动的回合，自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90727556,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c90727556.condition)
	e1:SetCost(c90727556.cost)
	e1:SetTarget(c90727556.target)
	e1:SetOperation(c90727556.operation)
	c:RegisterEffect(e1)
	-- 这张卡不能为名字带有「侵入魔鬼」的怪兽的上级召唤以外而解放
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetValue(c90727556.sumlimit)
	c:RegisterEffect(e3)
	-- 也不能作为同调素材
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 检查是否满足发动条件：处于自己主要阶段1的开始时，且自己场上没有魔法·陷阱卡存在
function c90727556.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1的开始时，且这张卡是「侵入魔鬼」怪兽
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity() and e:GetHandler():IsSetCard(0x100a)
		-- 检查自己场上是否存在魔法·陷阱卡
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 检查本回合是否进行过特殊召唤，并注册本回合不能特殊召唤其他怪兽的誓约效果
function c90727556.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合玩家是否进行过特殊召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 墓地存在的这张卡在自己场上特殊召唤。这个效果发动的回合，自己不能把怪兽特殊召唤。这张卡不能为名字带有「侵入魔鬼」的怪兽的上级召唤以外而解放
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c90727556.splimit)
	-- 给玩家注册不能特殊召唤其他怪兽的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制玩家不能特殊召唤，但允许此卡自身的效果进行特殊召唤
function c90727556.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabelObject()~=se
end
-- 检查怪兽区域是否有空位，以及此卡是否可以特殊召唤
function c90727556.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，将自身作为特殊召唤的对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤，将墓地的这张卡在自己场上特殊召唤
function c90727556.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 限制解放此卡进行上级召唤的怪兽必须是「侵入魔鬼」怪兽
function c90727556.sumlimit(e,c)
	return not c:IsSetCard(0x100a)
end
