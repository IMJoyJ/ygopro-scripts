--影騎士シメーリア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：连锁2以后对方把怪兽的效果发动时才能发动。那个效果变成「对方把自身的场上（表侧表示）·墓地1只「百夫长骑士」怪兽当作永续陷阱卡使用在自身的魔法与陷阱区域表侧表示放置」。这个回合，自己不能把「影骑士 奇美莉娅」特殊召唤。
-- ②：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 影骑士 奇美莉娅的初始化效果函数，注册①效果（效果变化）和②效果（自身特殊召唤）
function s.initial_effect(c)
	-- ①：连锁2以后对方把怪兽的效果发动时才能发动。那个效果变成「对方把自身的场上（表侧表示）·墓地1只「百夫长骑士」怪兽当作永续陷阱卡使用在自身的魔法与陷阱区域表侧表示放置」。这个回合，自己不能把「影骑士 奇美莉娅」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"效果变化"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.chcon)
	e1:SetTarget(s.chtg)
	e1:SetOperation(s.chop)
	c:RegisterEffect(e1)
	-- ②：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：连锁2以后对方把怪兽的效果发动时
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动效果的玩家是否为对方、发动的是否为怪兽效果、且当前连锁数是否大于等于2
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.GetCurrentChain()>=2
end
-- 过滤条件：属于「百夫长骑士」字段的怪兽，且可以放置在魔陷区
function s.mfilter(c,tp)
	return c:IsSetCard(0x1a2) and c:IsType(TYPE_MONSTER) and not c:IsForbidden() and c:IsFaceupEx() and c:CheckUniqueOnField(tp)
end
-- ①效果的发动检查：检查奇美莉娅的控制者（即对方怪兽效果控制者的对手）场上或墓地是否存在可放置的「百夫长骑士」怪兽，且其魔陷区有空位
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，确认奇美莉娅的控制者（即对方怪兽效果控制者的对手）的场上或墓地有至少1只满足条件的「百夫长骑士」怪兽，且其魔陷区有空位
	if chk==0 then return Duel.IsExistingMatchingCard(s.mfilter,rp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,rp) and Duel.GetLocationCount(1-rp,LOCATION_SZONE)>0 end
end
-- ①效果的处理：将对方连锁的效果变更为指定的放置效果，并对自身施加本回合不能特招「影骑士 奇美莉娅」的限制
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 清空该连锁的效果对象
	Duel.ChangeTargetCard(ev,g)
	-- 将该连锁的效果处理函数替换为自定义的变更后效果处理函数 s.repop
	Duel.ChangeChainOperation(ev,s.repop)
	-- 那个效果变成「对方把自身的场上（表侧表示）·墓地1只「百夫长骑士」怪兽当作永续陷阱卡使用在自身的魔法与陷阱区域表侧表示放置」。这个回合，自己不能把「影骑士 奇美莉娅」特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给自身玩家注册本回合不能特殊召唤「影骑士 奇美莉娅」的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 变更后的效果处理：由奇美莉娅的控制者选择自身场上或墓地的一只「百夫长骑士」怪兽，作为永续陷阱卡表侧表示放置到自身的魔陷区
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若奇美莉娅控制者的魔法与陷阱区域没有空位，则效果不处理
	if Duel.GetLocationCount(1-tp,LOCATION_SZONE)==0 then return end
	-- 向奇美莉娅的控制者显示提示信息：请选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让奇美莉娅的控制者从自身的场上（表侧表示）或墓地中选择1只满足条件的「百夫长骑士」怪兽（受墓地相关效果影响限制）
	local g=Duel.SelectMatchingCard(1-tp,aux.NecroValleyFilter(s.mfilter),1-tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,1-tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽表侧表示移动到奇美莉娅控制者的魔法与陷阱区域
		Duel.MoveToField(tc,1-tp,1-tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 当作永续陷阱卡使用在自身的魔法与陷阱区域表侧表示放置
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 特殊召唤限制：限制不能特殊召唤与本卡同名的怪兽
function s.splimit(e,c)
	return c:IsCode(id)
end
-- ②效果的发动条件：这张卡当作永续陷阱卡使用，且在自己或对方的主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and e:GetHandler():GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
-- ②效果的发动检查：检查自身怪兽区域是否有空位，且自身是否可以作为怪兽特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，确认自身怪兽区域有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且确认玩家可以特殊召唤具有本卡属性、种族、攻防等数值的怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1a2,TYPE_MONSTER+TYPE_EFFECT,1200,1600,4,RACE_PYRO,ATTRIBUTE_DARK) end
	-- 设置连锁的操作信息为：特殊召唤自身（1张卡）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：若本卡仍存在于魔陷区，则将其特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将本卡以表侧表示特殊召唤到自身场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
