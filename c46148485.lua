--転輪のスフィンクス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：怪兽的表示形式变更的场合，从自己墓地把1张魔法卡除外才能发动。这张卡从手卡·墓地特殊召唤。
-- ②：自己主要阶段才能发动。从自己的卡组·墓地把「太阳之书」和「月之书」各最多1张在自己的魔法与陷阱区域盖放。
-- ③：1回合1次，场上的其他怪兽的表示形式变更的场合，以场上1张卡为对象才能发动。那张卡回到手卡。
local s,id,o=GetID()
-- 初始化效果函数，注册三个效果
function s.initial_effect(c)
	-- 记录该卡拥有「太阳之书」和「月之书」的卡名
	aux.AddCodeList(c,38699854,14087893)
	-- 效果①：表示形式变更时，从墓地除外一张魔法卡才能发动，将此卡从手卡或墓地特殊召唤
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
	-- 效果②：自己主要阶段才能发动，从卡组或墓地将「太阳之书」和「月之书」各最多1张盖放
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- 效果③：场上的其他怪兽表示形式变更时，以场上1张卡为对象才能发动，那张卡回到手卡
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
-- 过滤函数，用于判断是否为魔法卡且能作为除外的费用
function s.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 效果①的费用处理函数，选择并除外一张墓地的魔法卡
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的魔法卡可作为除外费用
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的魔法卡组
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果①的目标设定函数，判断是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的发动处理函数，执行特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否与连锁相关且未受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断是否为「太阳之书」或「月之书」且可盖放
function s.setfilter(c)
	return c:IsCode(38699854,14087893) and c:IsSSetable()
end
-- 效果②的目标设定函数，判断是否有满足条件的卡可盖放
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的卡可盖放
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- 效果②的发动处理函数，选择并盖放「太阳之书」和「月之书」
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家魔法陷阱区域的可用数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	if ft>=2 then ft=2 end
	-- 获取满足条件的卡组（包括卡组和墓地）
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从符合条件的卡中选择不重复卡名的子集
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
		if sg:GetCount()>0 then
			-- 执行盖放操作
			Duel.SSet(tp,sg)
		end
	end
end
-- 效果③的发动条件函数，判断是否有其他怪兽表示形式变更
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有其他怪兽表示形式变更
	return eg:FilterCount(aux.TRUE,e:GetHandler())>0
end
-- 效果③的目标设定函数，选择一张可返回手牌的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 检查是否有满足条件的卡可返回手牌
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的卡作为目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示将该卡返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果③的发动处理函数，执行将目标卡返回手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将目标卡送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
