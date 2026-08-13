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
	-- 这个卡名的①的效果1回合只能使用1次。①：自己主要阶段才能发动。从自己卡组上面把3张卡翻开。可以从那之中选攻击力和守备力的数值相同的1只机械族怪兽加入手卡。剩下的卡里侧表示除外。
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
-- ①效果的发动条件判定函数：在自己卡组至少有3张卡且我方可以除外卡时，效果可发动。
function c24793135.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动检查时，要求自己卡组至少3张卡，且我方可以除外卡片。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 and Duel.IsPlayerCanRemove(tp) end
end
-- 定义①效果中可选加入手卡的卡的条件：攻击力与守备力相同的机械族怪兽，且能够加入手卡。
function c24793135.thfilter(c)
	-- 判定该卡是否为攻击力与守备力相同、机械族、且可以加入手卡的卡。
	return aux.AtkEqualsDef(c) and c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
-- 执行①效果：从卡组顶翻开3张；若其中有符合条件的卡且玩家选择“是”，则选1只加入手卡并展示给对方后洗手卡；其余卡里侧表示除外。
function c24793135.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 若我方不能除外卡片，则无法继续效果处理，直接结束。
	if not Duel.IsPlayerCanRemove(tp) then return end
	-- 若自己卡组不足3张，则无法翻开3张，直接结束。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	-- 向自己确认卡组最上方3张卡。
	Duel.ConfirmDecktop(tp,3)
	-- 取得卡组最上方3张卡作为处理对象组 g。
	local g=Duel.GetDecktopGroup(tp,3)
	if g:GetCount()>0 then
		-- 禁止本次效果处理后的自动洗卡检测，避免意外洗切卡组。
		Duel.DisableShuffleCheck()
		-- 若翻开的3张中存在符合条件的卡，且玩家选择“是”，则执行加入手卡的步骤。
		if g:IsExists(c24793135.thfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(24793135,1)) then  --"是否选卡加入手卡？"
			-- 显示“选择要加入手卡的卡”的提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:FilterSelect(tp,c24793135.thfilter,1,1,nil)
			-- 将选中的卡加入其持有者的手卡，处理原因为效果。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,sg)
			-- 洗切我方手卡，防止对方根据手牌顺序获取信息。
			Duel.ShuffleHand(tp)
			g:Sub(sg)
		end
		-- 将剩余未加入手卡的卡以里侧表示除外，处理原因包含效果和翻开。
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT+REASON_REVEAL)
	end
end
-- 定义②效果监听的怪兽条件：表侧表示、攻击力与守备力相同、机械族。
function c24793135.cfilter(c)
	-- 判断怪兽是否满足表侧表示、攻击力与守备力相同且为机械族。
	return aux.AtkEqualsDef(c) and c:IsRace(RACE_MACHINE) and c:IsFaceup()
end
-- ②效果的触发条件：召唤·特殊召唤成功的事件中存在满足条件的机械族怪兽。
function c24793135.countercon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c24793135.cfilter,1,nil)
end
-- ②效果处理：给这张卡放置1个指示物。
function c24793135.counterop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x5d,1)
end
-- ③效果的适用条件：这张卡的指示物数量达到10以上。
function c24793135.actlimitcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x5d)>=10
end
-- ③效果的判定函数：发动效果的卡若是位于怪兽区的怪兽，且该怪兽攻击力与守备力数值不同，则禁止其效果发动。
function c24793135.actlimit(e,re,tp)
	local loc=re:GetActivateLocation()
	local rc=re:GetHandler()
	return loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and rc:IsDefenseAbove(0) and not rc:IsDefense(rc:GetAttack())
end
