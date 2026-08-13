--鋼炎の剣士
-- 效果：
-- 这张卡不能通常召唤，用把5星以上的战士族怪兽解放发动的「金属化·强化反射装甲」的效果可以特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。把「钢炎之剑士」以外的有「金属化·强化反射装甲」的卡名记述的1张卡从卡组加入手卡，这张卡回到卡组。
-- ②：只要这张卡在怪兽区域存在，每次对方把效果发动，这张卡的攻击力上升300，给与对方500伤害。
local s,id,o=GetID()
-- 初始化钢炎之剑士的效果：登记效果文本中记载的「金属化·强化反射装甲」；设置不能通常召唤的召唤限制；注册①的起动效果（同名卡1回合1次，展示自身从卡组检索符合条件的卡并回到卡组）；注册②的诱发效果，通过两个持续效果在对方发动效果后提升攻击力并造成伤害。
function s.initial_effect(c)
	-- 将卡号89812483（金属化·强化反射装甲）登记为此卡效果文本中记载的卡，便于后续通过aux.IsCodeListed检查其他卡是否也记述了这张卡。
	aux.AddCodeList(c,89812483)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：把手卡的这张卡给对方观看才能发动。把「钢炎之剑士」以外的有「金属化·强化反射装甲」的卡名记述的1张卡从卡组加入手卡，这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，每次对方把效果发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	-- 这张卡的攻击力上升300，给与对方500伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.damcon)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
-- 定义素材过滤函数：判断解放的怪兽是否为表侧表示、等级5以上、战士族，作为「金属化·强化反射装甲」解放发动时可用特殊召唤素材的判定条件。
function s.mfilter(ft,lv,race,att)
	return ft==1 and lv>=5 and race&RACE_WARRIOR~=0
end
s.Metallization_material=s.mfilter
-- 代价判定：效果发动时确认这张手牌当前处于非公开状态（未公开），满足“把手卡的这张卡给对方观看”的发动条件。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 检索卡的过滤函数：要求不是「钢炎之剑士」自身、效果文本记载了「金属化·强化反射装甲」且能够加入手牌。
function s.thfilter(c)
	-- 判断检索对象的具体条件：不是本卡（id），且卡名中记述了「金属化·强化反射装甲」，并且当前可以被加入手牌。
	return not c:IsCode(id) and aux.IsCodeListed(c,89812483) and c:IsAbleToHand()
end
-- 目标判定与操作信息设置：确认卡组存在符合条件的检索卡且此卡本身能回卡组；若满足则设置从卡组将1张卡加入手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：卡组中存在至少1张符合s.thfilter的检索对象，并且这张钢炎之剑士本身能够回到卡组。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and c:IsAbleToDeck() end
	-- 设置效果处理信息：本次效果将从卡组把1张卡加入手牌（用于让其他卡进行对应检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：玩家从卡组选择1张符合条件的卡加入手牌并给对方确认；若这张钢炎之剑士仍与效果相关，则将其回到持有者卡组并洗牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 弹出选择提示，让玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足s.thfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片以效果原因加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示刚刚加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
		if c:IsRelateToEffect(e) then
			-- 将钢炎之剑士以效果原因弹回持有者卡组并洗牌（SEQ_DECKSHUFFLE表示洗牌）。
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 每当有卡发动效果时（后续再由damcon判断是否为对方），给这张钢炎之剑士注册一个标志，记录本连锁有效果发动；标志在连锁结束后重置。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
-- 伤害效果的处理条件：当前连锁中发动效果的玩家是对方，且这张卡身上存在之前记录的效果发动标志（即对方确实发动过效果）。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and c:GetFlagEffect(id)~=0
end
-- 效果处理：展示钢炎之剑士的发动动画；令这张卡攻击力上升300；给对方造成500点效果伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示钢炎之剑士的卡片动画，作为效果适用的提示。
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	-- 这张卡的攻击力上升300
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- 给对方玩家造成500点效果伤害。
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
