--剣闘獣ダレイオス
-- 效果：
-- 包含「剑斗兽」怪兽的怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从自己的手卡·墓地把1只4星以下的「剑斗兽」怪兽特殊召唤。对方场上有怪兽存在的场合，也能作为代替从卡组把1只「剑斗兽」怪兽特殊召唤。这个回合，自己不是「剑斗兽」怪兽不能作为连接素材。
-- ②：自己场上的「剑斗兽」怪兽在对方战斗阶段中不会被战斗·效果破坏。
local s,id,o=GetID()
-- 初始化卡片效果：添加连接召唤手续，注册连接召唤成功时特殊召唤的效果，以及战斗与效果破坏抗性。
function s.initial_effect(c)
	-- 添加连接召唤手续：需要2只怪兽作为素材，且必须包含「剑斗兽」怪兽。
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从自己的手卡·墓地把1只4星以下的「剑斗兽」怪兽特殊召唤。对方场上有怪兽存在的场合，也能作为代替从卡组把1只「剑斗兽」怪兽特殊召唤。这个回合，自己不是「剑斗兽」怪兽不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上的「剑斗兽」怪兽在对方战斗阶段中不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.indcon)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
end
-- 连接素材过滤条件：素材组中必须存在至少1只「剑斗兽」怪兽。
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x1019)
end
-- 效果①的发动条件：这张卡连接召唤成功。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 特殊召唤怪兽的过滤条件：是「剑斗兽」怪兽，且可以特殊召唤，并且在卡组中（对方场上有怪兽时）或者是4星以下。
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and (c:IsLocation(LOCATION_DECK) or c:IsLevelBelow(4))
end
-- 效果①的发动准备：确定特殊召唤的范围，检查自身怪兽区域是否有空位以及是否存在可特殊召唤的怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_HAND+LOCATION_GRAVE
	-- 检查对方场上是否存在怪兽。
	if Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) then
		loc=LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK
	end
	-- 检查自身场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查指定区域是否存在满足特殊召唤条件的「剑斗兽」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp) end
	-- 向对方玩家提示已选择发动该效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置特殊召唤的操作信息（包含手卡、墓地和卡组）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
end
-- 效果①的效果处理：特殊召唤符合条件的「剑斗兽」怪兽，并适用“这个回合，自己不是「剑斗兽」怪兽不能作为连接素材”的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身场上是否有可用的怪兽区域空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local loc=LOCATION_HAND+LOCATION_GRAVE
		-- 检查对方场上是否存在怪兽，以决定是否可以将卡组纳入特殊召唤的范围。
		if Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) then
			loc=LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK
		end
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从指定区域选择1只满足条件的「剑斗兽」怪兽（受王家长眠之谷影响）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,loc,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			-- 将选择的怪兽以表侧表示特殊召唤。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		end
	end
	-- 这个回合，自己不是「剑斗兽」怪兽不能作为连接素材。②：自己场上的「剑斗兽」怪兽在对方战斗阶段中不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0xff,0xff)
	-- 设置连接素材限制的对象：非「剑斗兽」怪兽。
	e1:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,0x1019)))
	e1:SetValue(s.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该连接素材限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制连接素材的适用范围：仅适用于自身控制的怪兽。
function s.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
-- 破坏抗性效果的启用条件：对方回合的战斗阶段。
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判断当前是否为对方回合的战斗阶段。
	return Duel.GetTurnPlayer()==1-e:GetHandlerPlayer() and (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
-- 破坏抗性效果的影响对象：自己场上的「剑斗兽」怪兽。
function s.indtg(e,c)
	return c:IsSetCard(0x1019)
end
