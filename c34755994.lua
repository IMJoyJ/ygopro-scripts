--聖魔の乙女アルテミス
-- 效果：
-- 4星以下的魔法师族怪兽1只
-- 自己对「圣魔之少女 阿耳特弥斯」1回合只能有1次特殊召唤，那些①②的效果1回合各能使用1次。
-- ①：这张卡在怪兽区域存在的状态，「大贤者」怪兽召唤·特殊召唤的场合，以那之内的1只为对象才能发动。自己场上的这张卡当作装备魔法卡使用给那只怪兽装备。
-- ②：这张卡装备中的场合才能发动。从卡组把1只「大贤者」怪兽加入手卡。
function c34755994.initial_effect(c)
	c:SetSPSummonOnce(34755994)
	-- 为卡片添加连接召唤手续，要求使用1到1个满足条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,c34755994.mfilter,1,1)
	c:EnableReviveLimit()
	-- ①：这张卡在怪兽区域存在的状态，「大贤者」怪兽召唤·特殊召唤的场合，以那之内的1只为对象才能发动。自己场上的这张卡当作装备魔法卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34755994,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,34755994)
	e1:SetCondition(c34755994.eqcon)
	e1:SetTarget(c34755994.eqtg)
	e1:SetOperation(c34755994.eqop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡装备中的场合才能发动。从卡组把1只「大贤者」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34755994,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,34755995)
	e3:SetCondition(c34755994.thcon)
	e3:SetTarget(c34755994.thtg)
	e3:SetOperation(c34755994.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数，判断怪兽是否为4星以下且为魔法师族
function c34755994.mfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkRace(RACE_SPELLCASTER)
end
-- 过滤函数，判断怪兽是否为表侧表示且为「大贤者」卡组
function c34755994.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x150)
end
-- 效果发动条件，判断是否有「大贤者」怪兽被召唤或特殊召唤且不包含自身
function c34755994.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c34755994.confilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 过滤函数，判断目标怪兽是否在指定的怪兽组中
function c34755994.eqfilter(c,g)
	return g:IsContains(c)
end
-- 设置效果目标，选择满足条件的怪兽作为装备对象
function c34755994.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c34755994.confilter,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c34755994.eqfilter(chkc,g) end
	-- 判断是否满足装备条件，检查场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否满足装备条件，检查是否存在满足条件的怪兽作为目标
		and Duel.IsExistingTarget(c34755994.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,g) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c34755994.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	-- 设置效果操作信息，表示将装备卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备效果的处理函数，将装备卡装备给目标怪兽并设置装备限制
function c34755994.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or not c:IsControler(tp) then return end
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断装备是否可以成功，检查是否有足够的魔法陷阱区域、目标怪兽是否合法
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将装备卡装备给目标怪兽
	if not Duel.Equip(tp,c,tc) then return end
	-- 创建装备限制效果，确保装备卡只能装备给特定怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetLabelObject(tc)
	e1:SetValue(c34755994.eqlimit)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 装备限制效果的判断函数，确保只能装备给指定的怪兽
function c34755994.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 效果发动条件，判断装备卡是否装备有怪兽
function c34755994.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
-- 过滤函数，判断卡是否为「大贤者」怪兽且可以加入手牌
function c34755994.thfilter(c)
	return c:IsSetCard(0x150) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果目标，检查卡组中是否存在满足条件的「大贤者」怪兽
function c34755994.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件，检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c34755994.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果操作信息，表示将1张「大贤者」怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数，从卡组选择1只「大贤者」怪兽加入手牌
function c34755994.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只「大贤者」怪兽加入手牌
	local g=Duel.SelectMatchingCard(tp,c34755994.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
