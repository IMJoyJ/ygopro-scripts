--パルマ・ライゼオル
-- 效果：
-- 这张卡不能通常召唤。从自己的手卡·墓地让1只「雷火沸动」怪兽回到卡组·额外卡组的场合可以特殊召唤。
-- ①：只要这张卡在怪兽区域存在，自己不是4阶超量怪兽不能从额外卡组特殊召唤。
-- ②：1回合1次，这张卡和对方怪兽进行战斗的伤害计算时才能发动。从手卡·卡组把1只4星怪兽送去墓地，这张卡的攻击力直到战斗阶段结束时上升那个攻击力数值。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含特殊召唤规则、额外卡组特殊召唤限制、以及伤害计算时上升攻击力的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己的手卡·墓地让1只「雷火沸动」怪兽回到卡组·额外卡组的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，自己不是4阶超量怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)
	-- ②：1回合1次，这张卡和对方怪兽进行战斗的伤害计算时才能发动。从手卡·卡组把1只4星怪兽送去墓地，这张卡的攻击力直到战斗阶段结束时上升那个攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"上升攻击力"
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
-- 过滤可以作为特殊召唤消耗返回卡组的卡片，需为手牌或墓地的「雷火沸动」怪兽。
function s.cfilter(c,tp)
	return (c:IsAbleToDeckAsCost() or c:IsAbleToExtraAsCost()) and c:IsSetCard(0x1be) and c:IsType(TYPE_MONSTER)
end
-- 特殊召唤规则的条件判断函数，检查怪兽区域是否有空位，且手牌或墓地是否存在满足条件的「雷火沸动」怪兽。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格，且手牌或墓地是否存在至少1只除自身以外满足条件的「雷火沸动」怪兽。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,e:GetHandler(),tp)
end
-- 特殊召唤规则的目标选择函数，让玩家选择1只手牌或墓地的「雷火沸动」怪兽，并将其记录在效果标签对象中。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己手牌和墓地中所有满足条件的「雷火沸动」怪兽卡组。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,e:GetHandler(),tp)
	-- 提示玩家选择要返回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的操作执行函数，将选中的卡片展示（若在手牌）或确认（若在墓地），然后将其返回卡组并洗牌。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local dc=e:GetLabelObject()
	if dc:IsLocation(LOCATION_HAND) then
		-- 给对方玩家确认从手牌中选择的卡片。
		Duel.ConfirmCards(1-tp,dc)
	end
	if dc:IsLocation(LOCATION_GRAVE) then
		-- 在墓地中高亮显示被选中的卡片。
		Duel.HintSelection(Group.FromCards(dc))
	end
	-- 将选中的卡片返回持有者的卡组并洗牌。
	Duel.SendtoDeck(dc,nil,SEQ_DECKSHUFFLE,REASON_SPSUMMON)
end
-- 限制自己不能从额外卡组特殊召唤4阶超量怪兽以外的怪兽。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsType(TYPE_XYZ) and c:IsRank(4)) and c:IsLocation(LOCATION_EXTRA)
end
-- 攻击力上升效果的发动条件判断，必须在这张卡与对方怪兽进行战斗时。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()
end
-- 过滤可以送去墓地的卡片，需为4星、攻击力不为0且能送去墓地的怪兽。
function s.tgfilter(c)
	return c:IsLevel(4) and not c:IsAttack(0) and c:IsAbleToGrave()
end
-- 攻击力上升效果的发动准备，检查手牌或卡组是否存在满足条件的4星怪兽，并设置送去墓地的操作信息。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果的检测阶段，检查自己手牌或卡组是否存在至少1只满足条件的4星怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果在处理时会将自己手牌或卡组的1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 攻击力上升效果的执行函数，选择1只4星怪兽送去墓地，并使这张卡的攻击力直到战斗阶段结束时上升该怪兽的攻击力数值。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌或卡组选择1只满足条件的4星怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	local c=e:GetHandler()
	local tc=g:GetFirst()
	-- 将选中的怪兽因效果送去墓地，并确认其已成功送去墓地。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		and c:IsRelateToBattle() and c:IsFaceup() then
		local atk=tc:GetAttack()
		-- 这张卡的攻击力直到战斗阶段结束时上升那个攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end
