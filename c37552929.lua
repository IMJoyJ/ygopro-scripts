--ミレニアムーン・メイデン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ②：这张卡是当作永续魔法卡使用的状态，对方的效果发动的场合才能发动。这张卡特殊召唤，这个回合中，对方不能把自己场上的5星以上的幻想魔族·魔法师族怪兽作为效果的对象。
-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
local s,id,o=GetID()
-- 注册三个效果：①手牌发动变为魔法卡放置、②对方发动效果时特殊召唤并限制对方怪兽效果对象、③战斗时不会被战斗破坏
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合才能发动。这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"当作魔法卡放置"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡是当作永续魔法卡使用的状态，对方的效果发动的场合才能发动。这张卡特殊召唤，这个回合中，对方不能把自己场上的5星以上的幻想魔族·魔法师族怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 效果处理：判断是否能将卡移至魔法陷阱区
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断目标区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 效果处理：将卡移至魔法陷阱区并改变其类型为魔法·永续
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 判断是否成功将卡移至魔法陷阱区
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 将卡的类型更改为魔法·永续
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
	end
end
-- 效果处理：判断是否为对方发动效果且卡处于魔法陷阱区
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_SPELL+TYPE_CONTINUOUS and rp~=tp
end
-- 效果处理：判断是否可以特殊召唤此卡并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以特殊召唤此卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1ae,TYPE_MONSTER+TYPE_EFFECT,1500,1300,4,RACE_ILLUSION,ATTRIBUTE_LIGHT) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：特殊召唤此卡并注册限制对方效果对象的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否可以特殊召唤此卡
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 注册限制对方效果对象的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.efftg)
		-- 设置限制对方效果对象的过滤函数
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将限制对方效果对象的效果注册给玩家
		Duel.RegisterEffect(e1,tp)
		-- 注册提示信息效果
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,2))  --"「千年月光少女」效果适用中"
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetTargetRange(1,0)
		-- 将提示信息效果注册给玩家
		Duel.RegisterEffect(e2,tp)
	end
end
-- 过滤函数：判断目标是否为5星以上幻想魔族或魔法师族怪兽
function s.efftg(e,c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_ILLUSION+RACE_SPELLCASTER)
end
-- 过滤函数：判断目标是否为自身或自身战斗对象
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
