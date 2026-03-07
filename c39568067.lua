--運命の旅路
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从卡组把有「勇者衍生物」的衍生物名记述的1只怪兽加入手卡。那之后，选自己1张手卡送去墓地。
-- ②：怪兽召唤·特殊召唤的场合才能发动。从卡组选有「勇者衍生物」的衍生物名记述的1张装备魔法卡加入手卡或给自己场上1只「勇者衍生物」装备。
-- ③：1回合只有1次，有装备卡装备的自己怪兽不会被战斗破坏。
function c39568067.initial_effect(c)
	-- 记录此卡效果文本上记载着「勇者衍生物」这张卡
	aux.AddCodeList(c,3285552)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己主要阶段才能发动。从卡组把有「勇者衍生物」的衍生物名记述的1只怪兽加入手卡。那之后，选自己1张手卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39568067,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,39568067)
	e1:SetTarget(c39568067.thtg)
	e1:SetOperation(c39568067.thop)
	c:RegisterEffect(e1)
	-- ②：怪兽召唤·特殊召唤的场合才能发动。从卡组选有「勇者衍生物」的衍生物名记述的1张装备魔法卡加入手卡或给自己场上1只「勇者衍生物」装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39568067,1))  --"检索装备"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,39568068)
	e2:SetTarget(c39568067.eqtg)
	e2:SetOperation(c39568067.eqop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：1回合只有1次，有装备卡装备的自己怪兽不会被战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(c39568067.indtg)
	e4:SetCountLimit(1)
	e4:SetValue(c39568067.indct)
	c:RegisterEffect(e4)
end
-- 检索满足条件的怪兽（有「勇者衍生物」的衍生物名记述且可加入手牌）
function c39568067.thfilter(c)
	-- 满足条件：有「勇者衍生物」的衍生物名记述、可加入手牌、是怪兽卡
	return aux.IsCodeListed(c,3285552) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
-- 判断是否满足①效果的发动条件：卡组是否存在满足条件的怪兽
function c39568067.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足①效果的发动条件：卡组是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c39568067.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置①效果的连锁操作信息：将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
-- ①效果的处理函数：选择并加入手牌、确认、洗牌、丢弃手牌
function c39568067.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c39568067.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 丢弃1张手牌
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT)
	end
end
-- 检索满足条件的装备魔法卡（有「勇者衍生物」的衍生物名记述且可加入手牌或装备）
function c39568067.eqfilter(c,equip,tp)
	-- 满足条件：是装备魔法卡、有「勇者衍生物」的衍生物名记述
	return c:IsType(TYPE_EQUIP) and aux.IsCodeListed(c,3285552)
		and (c:IsAbleToHand() or equip and c:CheckUniqueOnField(tp) and not c:IsForbidden())
end
-- 检索满足条件的「勇者衍生物」怪兽（正面表示）
function c39568067.cfilter(c)
	return c:IsCode(3285552) and c:IsFaceup()
end
-- 判断是否满足②效果的发动条件：卡组是否存在满足条件的装备魔法卡且自己场上有「勇者衍生物」怪兽
function c39568067.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 判断自己场上是否有可用的装备区
		local equip=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			-- 判断自己场上是否存在「勇者衍生物」怪兽
			and Duel.IsExistingMatchingCard(c39568067.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断是否满足②效果的发动条件：卡组是否存在满足条件的装备魔法卡且自己场上有「勇者衍生物」怪兽
		return Duel.IsExistingMatchingCard(c39568067.eqfilter,tp,LOCATION_DECK,0,1,nil,equip,tp)
	end
	-- 设置②效果的连锁操作信息：将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
-- ②效果的处理函数：选择并加入手牌或装备
function c39568067.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否有可用的装备区
	local equip=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断自己场上是否存在「勇者衍生物」怪兽
		and Duel.IsExistingMatchingCard(c39568067.cfilter,tp,LOCATION_MZONE,0,1,nil)
	-- 提示玩家选择要操作的装备魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选择满足条件的1张装备魔法卡
	local g=Duel.SelectMatchingCard(tp,c39568067.eqfilter,tp,LOCATION_DECK,0,1,1,nil,equip,tp)
	local tc=g:GetFirst()
	if g:GetCount()>0 then
		if equip and tc:CheckUniqueOnField(tp) and not tc:IsForbidden()
			-- 判断是否选择装备：满足条件且玩家选择装备
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,aux.Stringid(39568067,2))==1) then  --"装备"
			-- 提示玩家选择要装备的「勇者衍生物」怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 选择场上1只「勇者衍生物」怪兽
			local sc=Duel.SelectMatchingCard(tp,c39568067.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
			-- 将装备魔法卡装备给选中的怪兽
			Duel.Equip(tp,tc,sc:GetFirst())
		else
			-- 将装备魔法卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的装备魔法卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 判断目标怪兽是否装备有装备卡
function c39568067.indtg(e,c)
	return c:GetEquipCount()>0
end
-- 判断是否为战斗破坏
function c39568067.indct(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
