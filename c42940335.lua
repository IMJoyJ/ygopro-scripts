--ミミグル・スローン
-- 效果：
-- 1星「迷拟宝箱鬼」怪兽×2
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把这张卡1个超量素材取除才能发动。从自己的手卡·卡组·墓地把1只「迷拟宝箱鬼·领主」特殊召唤。
-- ②：自己·对方的主要阶段，以自己场上1只「迷拟宝箱鬼·领主」为对象才能发动。这张卡当作攻击力上升1000的装备魔法卡使用给那只怪兽装备。那之后，可以让最多有这张卡持有的超量素材数量的场上的卡回到手卡。
local s,id,o=GetID()
-- 初始化效果，注册卡片代码列表，设置XYZ召唤条件，启用复活限制，创建①②效果
function s.initial_effect(c)
	-- 记录该卡与「迷拟宝箱鬼·领主」的关联
	aux.AddCodeList(c,55537983)
	-- 设置XYZ召唤条件：需要1星且属于「迷拟宝箱鬼」的怪兽叠放，最少2只
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x1b7),1,2)
	c:EnableReviveLimit()
	-- 创建①效果：把这张卡1个超量素材取除才能发动。从自己的手卡·卡组·墓地把1只「迷拟宝箱鬼·领主」特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 创建②效果：自己·对方的主要阶段，以自己场上1只「迷拟宝箱鬼·领主」为对象才能发动。这张卡当作攻击力上升1000的装备魔法卡使用给那只怪兽装备。那之后，可以让最多有这张卡持有的超量素材数量的场上的卡回到手卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"装备"
	e2:SetCategory(CATEGORY_EQUIP+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- ①效果的费用处理：检查并移除1个超量素材
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选「迷拟宝箱鬼·领主」卡片的过滤函数
function s.spfilter(c,e,tp)
	return c:IsCode(55537983) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- ①效果的发动条件判断：检查是否有足够的怪兽区域和目标卡片
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否有满足条件的「迷拟宝箱鬼·领主」卡片
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤目标卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果的处理函数：选择并特殊召唤目标卡片
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「迷拟宝箱鬼·领主」卡片
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件判断：判断是否在主要阶段
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 筛选「迷拟宝箱鬼·领主」卡片的过滤函数
function s.eqfilter(c)
	return c:IsCode(55537983)
end
-- ②效果的目标选择处理：选择场上自己的「迷拟宝箱鬼·领主」怪兽作为目标
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	-- 检查是否有足够的装备区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查是否有满足条件的「迷拟宝箱鬼·领主」怪兽作为目标
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置操作信息：准备装备效果
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- ②效果的处理函数：装备并处理后续效果
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local ct=c:GetOverlayCount()
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断装备条件是否满足
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:GetControler()==1-tp or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试装备操作
	if not Duel.Equip(tp,c,tc) then return end
	-- 设置装备限制效果：只能装备给指定怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 设置装备后攻击力上升1000的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- 判断是否可以发动返回手牌效果：超量素材数量大于0且场上存在可返回手牌的卡，且玩家选择发动
	if ct>0 and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否让卡回到手卡？"
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择最多等于超量素材数量的场上卡返回手牌
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
		if #sg>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 显示选择的卡被选为对象的动画效果
			Duel.HintSelection(sg)
			-- 将选择的卡送入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end
-- 装备限制效果的判断函数：只能装备给指定的怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
