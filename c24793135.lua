--機巧伝－神使記紀図
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从自己卡组上面把3张卡翻开。可以从那之中选攻击力和守备力的数值相同的1只机械族怪兽加入手卡。剩下的卡里侧表示除外。
-- ②：每次攻击力和守备力的数值相同的机械族怪兽召唤·特殊召唤给这张卡放置1个指示物。
-- ③：这张卡的指示物数量是10以上的场合，攻击力和守备力的数值不同的场上的怪兽不能把效果发动。
function c24793135.initial_effect(c)
	c:EnableCounterPermit(0x5d,LOCATION_FZONE)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。从自己卡组上面把3张卡翻开。可以从那之中选攻击力和守备力的数值相同的1只机械族怪兽加入手卡。剩下的卡里侧表示除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24793135,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,24793135)
	e2:SetTarget(c24793135.thtg)
	e2:SetOperation(c24793135.thop)
	c:RegisterEffect(e2)
	-- ②：每次攻击力和守备力的数值相同的机械族怪兽召唤·特殊召唤给这张卡放置1个指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(c24793135.countercon)
	e3:SetOperation(c24793135.counterop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ③：这张卡的指示物数量是10以上的场合，攻击力和守备力的数值不同的场上的怪兽不能把效果发动。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(1,1)
	e5:SetCondition(c24793135.actlimitcon)
	e5:SetValue(c24793135.actlimit)
	c:RegisterEffect(e5)
end
-- 检查是否满足①效果的发动条件：玩家卡组数量不少于3张且玩家能除外卡片。
function c24793135.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足①效果的发动条件：玩家卡组数量不少于3张且玩家能除外卡片。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 and Duel.IsPlayerCanRemove(tp) end
end
-- 筛选函数：检查卡片是否满足攻击力等于守备力、种族为机械族且能加入手牌的条件。
function c24793135.thfilter(c)
	-- 筛选函数：检查卡片是否满足攻击力等于守备力、种族为机械族且能加入手牌的条件。
	return aux.AtkEqualsDef(c) and c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
-- ①效果的处理函数：确认卡组顶部3张卡，选择符合条件的怪兽加入手牌，其余卡除外。
function c24793135.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否能除外卡片，否则不执行效果。
	if not Duel.IsPlayerCanRemove(tp) then return end
	-- 检查玩家卡组是否至少有3张卡，否则不执行效果。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	-- 翻开玩家卡组顶部3张卡。
	Duel.ConfirmDecktop(tp,3)
	-- 获取玩家卡组顶部3张卡组成的卡片组。
	local g=Duel.GetDecktopGroup(tp,3)
	if g:GetCount()>0 then
		-- 禁用后续操作的洗卡检测。
		Duel.DisableShuffleCheck()
		-- 判断翻开的卡中是否存在满足条件的怪兽，并询问玩家是否选择加入手牌。
		if g:IsExists(c24793135.thfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(24793135,1)) then  --"是否选卡加入手卡？"
			-- 提示玩家选择要加入手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:FilterSelect(tp,c24793135.thfilter,1,1,nil)
			-- 将符合条件的卡加入玩家手牌。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方确认玩家选择加入手牌的卡。
			Duel.ConfirmCards(1-tp,sg)
			-- 洗切玩家手牌。
			Duel.ShuffleHand(tp)
			g:Sub(sg)
		end
		-- 将剩余的卡以里侧表示形式除外。
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT+REASON_REVEAL)
	end
end
-- 筛选函数：检查卡片是否满足攻击力等于守备力、种族为机械族且处于表侧表示的条件。
function c24793135.cfilter(c)
	-- 筛选函数：检查卡片是否满足攻击力等于守备力、种族为机械族且处于表侧表示的条件。
	return aux.AtkEqualsDef(c) and c:IsRace(RACE_MACHINE) and c:IsFaceup()
end
-- 判断是否满足②效果的发动条件：有满足条件的怪兽被召唤或特殊召唤。
function c24793135.countercon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c24793135.cfilter,1,nil)
end
-- ②效果的处理函数：给这张卡放置1个指示物。
function c24793135.counterop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x5d,1)
end
-- 判断是否满足③效果的发动条件：这张卡的指示物数量不少于10。
function c24793135.actlimitcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x5d)>=10
end
-- ③效果的处理函数：禁止攻击力和守备力不同的场上怪兽发动效果。
function c24793135.actlimit(e,re,tp)
	local loc=re:GetActivateLocation()
	local rc=re:GetHandler()
	return loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and rc:IsDefenseAbove(0) and not rc:IsDefense(rc:GetAttack())
end
