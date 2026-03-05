--ニュービー！
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己墓地有攻击力和守备力是0的怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡从手卡特殊召唤的场合才能发动。以下效果各能适用。
-- ●「菜鸟新蜂族！」以外的自己墓地1只昆虫族·光属性怪兽加入手卡。
-- ●自己的墓地·除外状态的1张陷阱卡回到卡组最上面或最下面。
local s,id,o=GetID()
-- 创建两个效果，一个用于特殊召唤条件，一个用于特殊召唤成功后的发动效果
function s.initial_effect(c)
	-- ①：自己墓地有攻击力和守备力是0的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡特殊召唤的场合才能发动。以下效果各能适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.accon)
	e2:SetTarget(s.actg)
	e2:SetOperation(s.acop)
	c:RegisterEffect(e2)
end
-- 过滤满足攻击力和守备力为0的怪兽
function s.filter(c)
	return c:IsAttack(0) and c:IsDefense(0) and c:IsType(TYPE_MONSTER)
end
-- 判断是否满足特殊召唤条件：场上存在空位且墓地存在攻击力和守备力为0的怪兽
function s.spcon(e,c)
	if c==nil then return true end
	-- 判断场上是否存在空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.filter,c:GetControler(),LOCATION_GRAVE,0,1,nil)
end
-- 判断此卡是否由手卡特殊召唤
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_HAND)
end
-- 过滤满足种族为昆虫族且属性为光的怪兽
function s.thfilter(c)
	return not c:IsCode(id) and c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 过滤满足为正面表示且为陷阱卡的卡
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_TRAP) and c:IsAbleToDeck()
end
-- 判断是否满足发动条件：墓地或除外状态存在满足条件的怪兽或陷阱卡
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断墓地或除外状态是否存在满足条件的怪兽或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) or Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
end
-- 处理发动效果：选择将怪兽加入手卡或陷阱卡回到卡组
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断墓地是否存在满足条件的怪兽
	local b1=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil)
	-- 判断墓地或除外状态是否存在满足条件的陷阱卡
	local b2=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	local res=false
	-- 若存在怪兽且陷阱卡不存在或玩家选择使用怪兽效果
	if b1 and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then  --"是否把怪兽加入手卡？"
		res=true
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择一张满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽送入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认送入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
	-- 若存在陷阱卡且未使用怪兽效果或玩家选择使用陷阱效果
	if b2 and (not res or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then  --"是否让陷阱回到卡组？"
		if res then
			-- 中断当前效果处理
			Duel.BreakEffect()
		end
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择一张满足条件的陷阱卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		if g:GetCount()>0 then
			-- 显示选中的陷阱卡被选为对象
			Duel.HintSelection(g)
			-- 判断卡组是否为空
			if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then
				-- 将陷阱卡送回卡组最底端
				Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			else
				-- 提示玩家选择将陷阱卡放回卡组最上面或最下面
				local opt=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))  --"卡组最上面/卡组最下面"
				if opt==0 then
					-- 将陷阱卡送回卡组最顶端
					Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
				else
					-- 将陷阱卡送回卡组最底端
					Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
				end
			end
		end
	end
end
