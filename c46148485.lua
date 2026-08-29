--転輪のスフィンクス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：怪兽的表示形式变更的场合，从自己墓地把1张魔法卡除外才能发动。这张卡从手卡·墓地特殊召唤。
-- ②：自己主要阶段才能发动。从自己的卡组·墓地把「太阳之书」和「月之书」各最多1张在自己的魔法与陷阱区域盖放。
-- ③：1回合1次，场上的其他怪兽的表示形式变更的场合，以场上1张卡为对象才能发动。那张卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 记录卡片记载的卡名（太阳之书、月之书）
	aux.AddCodeList(c,38699854,14087893)
	-- ①：怪兽的表示形式变更的场合，从自己墓地把1张魔法卡除外才能发动。这张卡从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从自己的卡组·墓地把「太阳之书」和「月之书」各最多1张在自己的魔法与陷阱区域盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，场上的其他怪兽的表示形式变更的场合，以场上1张卡为对象才能发动。那张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤可作为代价除外的魔法卡
function s.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤效果的发动代价（从墓地把1张魔法卡除外）
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在可作为代价除外的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张魔法卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的卡作为代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤效果的目标确认与操作信息设置
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主要怪兽区空位及自身特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤自身的操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否仍关联连锁且不受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将自身以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤可盖放的「太阳之书」或「月之书」
function s.setfilter(c)
	return c:IsCode(38699854,14087893) and c:IsSSetable()
end
-- 盖放效果的目标确认
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地是否存在可盖放的「太阳之书」或「月之书」
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- 从卡组·墓地盖放「太阳之书」和「月之书」
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自身魔法与陷阱区域的空余格子数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	if ft>=2 then ft=2 end
	-- 获取卡组及墓地中不受王家长眠之谷影响的可盖放卡片组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 then
		-- 提示选择要盖放的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡片组中选择最多不超过可用空位数量的不同卡名卡片
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
		if sg then
			-- 将选择的卡在魔法与陷阱区域盖放
			Duel.SSet(tp,sg)
		end
	end
end
-- 判断场上其他怪兽表示形式变更的发动条件
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断变更表示形式的怪兽中是否存在除自身以外的怪兽
	return eg:FilterCount(aux.TRUE,e:GetHandler())>0
end
-- 弹回手卡效果的对象选择与操作信息设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 检查场上是否存在可返回手牌的目标卡片
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置将目标卡片返回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行将目标卡片返回手牌的操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将目标卡片因效果返回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
