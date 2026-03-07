--ARG☆S－屠龍のエテオ
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的战士族怪兽不会被效果破坏。
-- ②：1回合1次，对方把效果发动时才能发动。这张卡变成持有以下效果的效果怪兽（战士族·光·4星·攻/守800）在怪兽区域特殊召唤（也当作陷阱卡使用）。自己的「阿尔戈☆群星」怪兽除外中的场合，可以再让场上1张卡回到手卡。
-- ●自己·对方回合1次，可以发动。这张卡在自己的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 初始化卡片效果，注册魔陷发动、永续效果、特殊召唤和表侧表示放置效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在魔法与陷阱区域存在，自己场上的战士族怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indfilter)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 1回合1次，对方把效果发动时才能发动。这张卡变成持有以下效果的效果怪兽（战士族·光·4星·攻/守800）在怪兽区域特殊召唤（也当作陷阱卡使用）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- 自己·对方回合1次，可以发动。这张卡在自己的魔法与陷阱区域表侧表示放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"表侧表示放置"
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1)
	e4:SetHintTiming(0,TIMING_MAIN_END)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- 过滤目标怪兽是否为战士族
function s.indfilter(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 判断是否为对方发动效果
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 设置特殊召唤效果的发动条件和目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断目标怪兽是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:GetFlagEffect(id)==0
		-- 判断玩家是否可以特殊召唤指定参数的怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1c1,TYPES_EFFECT_TRAP_MONSTER,800,800,4,RACE_WARRIOR,ATTRIBUTE_LIGHT) end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤效果并可选择让场上的卡回到手牌
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断玩家是否可以特殊召唤指定参数的怪兽
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1c1,TYPES_EFFECT_TRAP_MONSTER,800,800,4,RACE_WARRIOR,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将该卡以特殊召唤方式特殊召唤到场上
	if Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)~=0
		-- 判断场上是否存在己方「阿尔戈☆群星」怪兽（除外状态）
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_REMOVED,0,1,nil)
		-- 判断场上是否存在可回到手牌的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 询问玩家是否让卡回到手牌
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否让卡回到手卡？"
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择场上一张可回到手牌的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 显示被选为对象的卡
			Duel.HintSelection(g)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将选中的卡送回手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
-- 过滤己方除外状态的「阿尔戈☆群星」怪兽
function s.cfilter2(c)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1c1)
end
-- 判断该卡是否为特殊召唤且未被战斗破坏
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 设置表侧表示放置效果的发动条件和目标
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断目标玩家是否有足够的魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():IsCanBePlacedOnField() end
end
-- 执行表侧表示放置效果
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断目标玩家是否有足够的魔法与陷阱区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡移动到目标玩家的魔法与陷阱区域
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
