--生ける屍の呼び声
-- 效果：
-- 这张卡发动时：可以从自己的卡组·墓地把最多3张「活死人的呼声」在自己场上盖放，直到下个对方回合的结束时，除从墓地的特殊召唤外，自己不是不死族怪兽不能特殊召唤。
-- 1回合1次，自己把「活死人的呼声」发动的场合：可以以对方场上1只怪兽为对象；那只怪兽送去墓地。
-- 「怨念的呼声」在1回合只能发动1张。
local s,id,o=GetID()
-- 初始化卡片效果：注册①发动时盖放卡组·墓地「活死人的呼声」及特召限制效果、②「活死人的呼声」发动时送墓对方怪兽效果
function s.initial_effect(c)
	-- 注册卡片记述列表：记述「活死人的呼声」
	aux.AddCodeList(c,97077563)
	-- ①：这张卡发动时：可以从自己的卡组·墓地把最多3张「活死人的呼声」在自己场上盖放，直到下个对方回合的结束时，除从墓地的特殊召唤外，自己不是不死族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己把「活死人的呼声」发动的场合：可以以对方场上1只怪兽为对象才能发动。那只怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 盖放过滤条件：卡号为「活死人的呼声」且可以盖放
function s.setfilter(c)
	return c:IsCode(97077563) and c:IsSSetable()
end
-- ①效果处理：从卡组·墓地盖放最多3张「活死人的呼声」，并注册直到下个对方回合结束的特召限制
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组·墓地所有不受王谷影响的「活死人的呼声」
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	-- 获取魔陷区域空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 询问玩家是否要把「活死人的呼声」盖放
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) and ft>0 then  --"是否把卡盖放？"
		local ct=math.min(3,ft)
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local sg=g:Select(tp,1,ct,nil)
		-- 将选中的卡在场上盖放
		Duel.SSet(tp,sg)
		-- 直到下个对方回合的结束时，除从墓地的特殊召唤外，自己不是不死族怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))  --"「怨念的呼声」效果适用中"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.slim)
		-- 给玩家注册全局特殊召唤限制效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 特召限制条件：禁止非墓地出处且非不死族的怪兽特殊召唤
function s.slim(e,c,sp,st,spos,tp,se)
	return not c:IsLocation(LOCATION_GRAVE) and not c:IsRace(RACE_ZOMBIE)
end
-- ②效果发动条件：自己把「活死人的呼声」发动
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(97077563) and rp==tp
end
-- ②效果发动准备：选择对方场上1只怪兽为对象并设置送墓操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 发动条件检查：对方场上是否存在可送去墓地的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上1只怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：将1只怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- ②效果处理：将对象怪兽送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将对象怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
