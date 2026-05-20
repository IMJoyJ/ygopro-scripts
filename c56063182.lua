--肆世壊＝ライフォビア
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「恐吓爪牙族」怪兽或者「维萨斯-斯塔弗罗斯特」加入手卡。
-- ②：对方场上的怪兽的攻击力·守备力下降场上的守备表示怪兽数量×100。
-- ③：场上有守备表示怪兽3只以上存在的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡片效果（发动时的检索效果、降低攻守的永续效果、破坏场上卡的起动效果）
function c56063182.initial_effect(c)
	-- 将「维萨斯-斯塔弗罗斯特」（卡号56099748）加入该卡的关联卡片密码列表中
	aux.AddCodeList(c,56099748)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「恐吓爪牙族」怪兽或者「维萨斯-斯塔弗罗斯特」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,56063182+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c56063182.activate)
	c:RegisterEffect(e1)
	-- ②：对方场上的怪兽的攻击力·守备力下降场上的守备表示怪兽数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c56063182.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ③：场上有守备表示怪兽3只以上存在的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(56063182,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,56063182+o)
	e4:SetCondition(c56063182.descon)
	e4:SetTarget(c56063182.destg)
	e4:SetOperation(c56063182.desop)
	c:RegisterEffect(e4)
end
-- 过滤卡组中属于「恐吓爪牙族」的怪兽或卡名为「维萨斯-斯塔弗罗斯特」且能加入手牌的卡
function c56063182.filter(c)
	return ((c:IsSetCard(0x17a) and c:IsType(TYPE_MONSTER)) or c:IsCode(56099748)) and c:IsAbleToHand()
end
-- 场地魔法发动时的效果处理：可以从卡组将1只符合条件的怪兽加入手牌
function c56063182.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足过滤条件的卡片组
	local g=Duel.GetMatchingGroup(c56063182.filter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在符合条件的卡，则询问玩家是否选择发动该检索效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(56063182,0)) then  --"是否从卡组把怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 计算对方场上怪兽攻击力（及守备力）下降的数值
function c56063182.atkval(e)
	-- 返回场上守备表示怪兽数量乘以-100的数值
	return Duel.GetMatchingGroupCount(Card.IsDefensePos,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)*-100
end
-- 破坏效果的发动条件：场上存在3只或以上的守备表示怪兽
function c56063182.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上的守备表示怪兽数量是否大于或等于3
	return Duel.GetMatchingGroupCount(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,nil)>=3
end
-- 破坏效果的发动准备（检查合法性、选择对方场上的1张卡作为对象并设置破坏操作信息）
function c56063182.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 效果发动时的合法性检查：对方场上是否存在可以作为对象的目标卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上的1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息，表明该效果包含破坏1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理：若对象卡仍合法存在，则将其破坏
function c56063182.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的第一个对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
