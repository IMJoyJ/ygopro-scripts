--帝王の策略
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从卡组把「帝王的策略」以外的1张「帝王」魔法·陷阱卡送去墓地。
-- ②：这张卡被除外的场合，以对方场上1只表侧表示怪兽为对象才能发动。属性和那只怪兽相同而攻击力2400/守备力1000的1只怪兽从自己的卡组·墓地加入手卡。那之后，以下效果可以适用。
-- ●进行「雷帝 扎博尔格」「冰帝 美比乌斯」「炎帝 泰斯塔罗斯」「地帝 格兰玛格」「风帝 莱扎」「邪帝 盖乌斯」的其中1只的召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（发动时送墓）和②效果（除外时检索并可选召唤）
function s.initial_effect(c)
	-- 将「雷帝 扎博尔格」「冰帝 美比乌斯」「炎帝 泰斯塔罗斯」「地帝 格兰玛格」「风帝 莱扎」「邪帝 盖乌斯」的卡片密码加入该卡的关联卡片列表中
	aux.AddCodeList(c,4929256,9748752,26205777,51945556,60229110,73125233)
	-- ①：从卡组把「帝王的策略」以外的1张「帝王」魔法·陷阱卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，以对方场上1只表侧表示怪兽为对象才能发动。属性和那只怪兽相同而攻击力2400/守备力1000的1只怪兽从自己的卡组·墓地加入手卡。那之后，以下效果可以适用。●进行「雷帝 扎博尔格」「冰帝 美比乌斯」「炎帝 泰斯塔罗斯」「地帝 格兰玛格」「风帝 莱扎」「邪帝 盖乌斯」的其中1只的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中除「帝王的策略」以外的「帝王」魔法·陷阱卡，且该卡能送去墓地
function s.filter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id) and c:IsAbleToGrave()
end
-- ①效果的发动准备，检查卡组中是否存在可送墓的「帝王」魔陷，并设置送去墓地的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「帝王」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示将从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理，让玩家从卡组选择1张满足条件的「帝王」魔陷送去墓地
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从卡组选择1张满足过滤条件的「帝王」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤攻击力2400、守备力1000、属性与指定属性相同且能加入手卡的怪兽
function s.thfilter(c,att)
	return c:IsAttack(2400) and c:IsDefense(1000) and c:IsAttribute(att)
		and c:IsAbleToHand()
end
-- 过滤对方场上表侧表示的怪兽，要求其属性在己方卡组或墓地中存在对应的攻击力2400/守备力1000的怪兽
function s.tgfilter(c,tp)
	local att=c:GetAttribute()
	-- 检查该怪兽是否表侧表示，且己方卡组或墓地中是否存在与其属性相同、攻击力2400/守备力1000的怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,att)
end
-- ②效果的发动准备，选择对方场上1只表侧表示怪兽作为对象，并设置检索/回收的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.tgfilter(chkc,tp) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为效果对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择对方场上1只满足条件的表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置连锁处理的操作信息，表示将从卡组或墓地将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 过滤手卡或场上可以进行通常召唤的特定帝王怪兽（雷帝、冰帝、炎帝、地帝、风帝、邪帝）
function s.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsCode(4929256,9748752,26205777,51945556,60229110,73125233)
end
-- ②效果的实际处理，将对应属性的怪兽加入手卡，并可选进行特定帝王怪兽的召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToChain() or not tc:IsType(TYPE_MONSTER) or not tc:IsFaceup() then return end
	local att=tc:GetAttribute()
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组或墓地选择1张与对象怪兽属性相同且攻击力2400/守备力1000的怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,att)
	-- 如果成功将选择的怪兽加入手卡
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 向对方玩家展示加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
		-- 获取手卡或场上满足召唤条件的特定帝王怪兽
		local sumg=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		-- 如果存在可召唤的怪兽，询问玩家是否适用后续效果进行召唤
		if sumg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否进行召唤？"
			-- 提示玩家选择要召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			local sc=sumg:Select(tp,1,1,nil):GetFirst()
			if sc then
				-- 中断当前效果处理，使后续的召唤处理与加入手卡不视为同时进行
				Duel.BreakEffect()
				-- 洗切玩家的手卡
				Duel.ShuffleHand(tp)
				-- 让玩家对选择的怪兽进行通常召唤（无视每回合通常召唤次数限制）
				Duel.Summon(tp,sc,true,nil)
			end
		end
	end
end
