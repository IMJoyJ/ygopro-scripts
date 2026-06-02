--天空城塞クーロン
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：从手卡召唤·特殊召唤的自己场上的怪兽的攻击力·守备力上升500。
-- ②：自己主要阶段才能发动。在对方场上把1只「机兽衍生物」（机械族·地·6星·攻/守2000）特殊召唤，从卡组把1只「雷盟」怪兽加入手卡。
-- ③：这张卡在墓地存在的状态，自己的「雷盟」卡的效果把卡破坏的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果：①从手卡召唤·特召的怪兽攻防上升500；②主要阶段在对方场上特召「机兽衍生物」并检索1只「雷盟」怪兽；③墓地状态下，自己的「雷盟」卡将卡破坏时，这张卡加入手卡
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：从手卡召唤·特殊召唤的自己场上的怪兽的攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：自己主要阶段才能发动。在对方场上把1只「机兽衍生物」（机械族·地·6星·攻/守2000）特殊召唤，从卡组把1只「雷盟」怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"特殊召唤并检索"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	-- ③：这张卡在墓地存在的状态，自己的「雷盟」卡的效果把卡破坏的场合才能发动。这张卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))  --"回到手卡"
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,id+o)
	e5:SetCondition(s.thcon)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
-- 过滤条件：是否是从手卡进行召唤或特殊召唤的怪兽
function s.atktg(e,c)
	return c:IsSummonLocation(LOCATION_HAND)
end
-- 过滤条件：卡组中属于「雷盟」系列的怪兽，且能加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x1df) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果2的发动准备与合法性检查：检查对方场上是否有空闲怪兽区域、是否可特殊召唤该衍生物、以及自己卡组是否存在可检索的「雷盟」怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少一个空余怪兽区域
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以向对方场上特殊召唤特定的衍生物怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,2000,2000,6,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP,1-tp)
		-- 检查卡组中是否存在可以检索的「雷盟」怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置操作信息：特殊召唤1只衍生物怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果2的实际处理：若对方场上有空位且能特召，则在对方场上特殊召唤1只「机兽衍生物」，特召成功后，从卡组检索1只「雷盟」怪兽并展示
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否拥有可用于召唤的空格子
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查是否可以向对方场上特殊召唤该衍生物怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,2000,2000,6,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP,1-tp) then
		-- 在内存中创建「机兽衍生物」的卡片实例
		local token=Duel.CreateToken(tp,id+o)
		-- 将该衍生物表侧表示特殊召唤至对方场上，并判断是否成功
		if Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)~=0 then
			-- 向玩家提示选择要加入手卡的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 让玩家从卡组中选择1只符合条件的「雷盟」怪兽
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if g:GetCount()>0 then
				-- 将选中的「雷盟」怪兽从卡组加入手卡
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 向对方玩家确认加入手卡的「雷盟」怪兽
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
-- 过滤条件：因效果原因被破坏的卡
function s.dcfilter(c)
	return c:IsReason(REASON_EFFECT)
end
-- 效果3的触发条件检查：检查在墓地状态下，是否是由于自己场上的「雷盟」卡片的效果把卡破坏
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and rp==tp and eg:IsExists(s.dcfilter,1,c) and re:GetHandler():IsSetCard(0x1df)
end
-- 效果3的发动准备与操作信息注册：确认此卡可从墓地加入手卡，并注册回收操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将墓地中的这张卡自身加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果3的实际处理：若此卡在连锁处理时仍合法存在于墓地且不受「王家长眠之谷」影响，则将其加入手卡并展示给对方
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡自身依然存在于墓地（与连锁相关）且不受「王家长眠之谷」影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡自身从墓地加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手手的这张卡
		Duel.ConfirmCards(1-tp,c)
	end
end
