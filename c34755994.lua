--聖魔の乙女アルテミス
-- 效果：
-- 4星以下的魔法师族怪兽1只
-- 自己对「圣魔之少女 阿耳特弥斯」1回合只能有1次特殊召唤，那些①②的效果1回合各能使用1次。
-- ①：这张卡在怪兽区域存在的状态，「大贤者」怪兽召唤·特殊召唤的场合，以那之内的1只为对象才能发动。自己场上的这张卡当作装备魔法卡使用给那只怪兽装备。
-- ②：这张卡装备中的场合才能发动。从卡组把1只「大贤者」怪兽加入手卡。
function c34755994.initial_effect(c)
	c:SetSPSummonOnce(34755994)
	-- 为这张卡添加连接召唤手续：使用1只满足mfilter条件（4星以下的魔法师族怪兽）的怪兽作为连接素材。
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
-- 连接素材过滤：等级4以下且种族为魔法师族的怪兽（IsLinkRace用于连接召唤素材的种族判定）。
function c34755994.mfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkRace(RACE_SPELLCASTER)
end
-- 判定「大贤者」怪兽：表侧表示且卡名含有0x150字段。
function c34755994.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x150)
end
-- 触发条件：本次召唤/特殊召唤成功的怪兽组中存在表侧表示的「大贤者」怪兽，且该组不包含这张卡自身。
function c34755994.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c34755994.confilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 对象过滤：判断一张卡是否属于当前召唤/特殊召唤成功的「大贤者」怪兽集合g。
function c34755994.eqfilter(c,g)
	return g:IsContains(c)
end
-- 目标选择：从本次召唤/特殊召唤成功的「大贤者」怪兽中选择1只作为装备对象。
function c34755994.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c34755994.confilter,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c34755994.eqfilter(chkc,g) end
	-- 发动时检查自己魔陷区是否有空位，用于把这张卡装备给对象。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且场上存在合法的装备对象：本次召唤/特殊召唤的「大贤者」怪兽中，有能成为这张卡装备对象的怪兽。
		and Duel.IsExistingTarget(c34755994.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,g) end
	-- 给玩家显示“请选择要装备的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只本次召唤/特殊召唤的「大贤者」怪兽，并将其登记为效果对象。
	Duel.SelectTarget(tp,c34755994.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	-- 设定操作信息：本次效果处理包含装备这张卡自身（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡装备给对象；若无法装备则送去墓地；装备成功后追加仅能装备给该对象的限制。
function c34755994.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or not c:IsControler(tp) then return end
	-- 获取选择的装备对象（那只「大贤者」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 当魔陷区没有空位、对象变成里侧表示或对象与此效果不再关联时，无法进行装备。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 因无法满足装备条件，将这张卡以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试把这张卡作为装备魔法卡装备给对象，若失败则直接结束处理。
	if not Duel.Equip(tp,c,tc) then return end
	-- 自己场上的这张卡当作装备魔法卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetLabelObject(tc)
	e1:SetValue(c34755994.eqlimit)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 装备限制：只有被选中的那只怪兽（e:GetLabelObject()）才能装备这张卡。
function c34755994.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ②发动条件：这张卡目前作为装备卡装备在怪兽身上（GetEquipTarget返回装备对象）。
function c34755994.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
-- 检索过滤：卡组中存在「大贤者」字段的怪兽且可以加入手牌。
function c34755994.thfilter(c)
	return c:IsSetCard(0x150) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②目标选择：判断卡组是否有可检索的「大贤者」怪兽，并设定操作信息。
function c34755994.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己卡组是否存在1张以上满足条件的「大贤者」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c34755994.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时包含从卡组将1张卡加入手牌的动作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只「大贤者」怪兽加入手牌，并展示给对方。
function c34755994.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1只满足条件（「大贤者」字段怪兽且能加入手牌）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c34755994.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认刚刚加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
