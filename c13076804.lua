--カオス・デーモン－混沌の魔神－
-- 效果：
-- 光属性调整＋调整以外的暗属性怪兽1只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这个回合是已有卡被除外的场合，这张卡的攻击力上升2000。
-- ②：这张卡可以向对方怪兽全部各作1次攻击，这张卡战斗破坏的怪兽不去墓地而除外。
-- ③：这张卡因对方从场上离开的场合才能发动。「混沌之魔神」以外的1只「混沌」同调怪兽从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- 添加同调召唤手续，需要1只光属性调整和1只暗属性调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_DARK),1)
	c:EnableReviveLimit()
	-- ①：这个回合是已有卡被除外的场合，这张卡的攻击力上升2000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.rmcon)
	e1:SetValue(2000)
	c:RegisterEffect(e1)
	-- ②：这张卡可以向对方怪兽全部各作1次攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏的怪兽不去墓地而除外
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e3)
	-- ③：这张卡因对方从场上离开的场合才能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		-- 当有卡被除外时，为玩家0注册一个标识效果，用于记录是否在本回合有卡被除外
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_REMOVE)
		ge1:SetOperation(s.checkop)
		-- 将全局效果ge1注册给玩家0
		Duel.RegisterEffect(ge1,0)
	end
end
-- 处理除外事件的全局效果函数
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家0注册一个在结束阶段重置的标识效果，表示本回合有卡被除外
	Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否在本回合有卡被除外的效果条件函数
function s.rmcon(e)
	-- 检查玩家0是否拥有标识效果id
	return Duel.GetFlagEffect(0,id)>0
end
-- 判断是否满足特殊召唤条件的函数
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 筛选可以特殊召唤的「混沌」同调怪兽的过滤函数
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0xcf) and c:IsType(TYPE_SYNCHRO)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否有足够的召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置特殊召唤操作信息的函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行特殊召唤操作的函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的1只怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
