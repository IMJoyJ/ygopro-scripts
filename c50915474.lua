--表裏の女神
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「表里之女神」以外的1只持有进行投掷硬币效果的怪兽加入手卡。
-- ②：自己主要阶段才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，自己场上的全部怪兽的攻击力直到回合结束时变成2倍。猜错的场合，自己场上的怪兽全部送去墓地，自己抽1张。
local s,id,o=GetID()
-- 初始化函数：给这张卡注册①与②两个效果。①为召唤·特殊召唤成功时触发的检索效果（先注册召唤，再克隆出特殊召唤）；②为在主要阶段发动的掷硬币效果，猜中时全场怪兽攻击力翻倍，猜错时全场怪兽送墓并抽1张，并各自设置1回合1次限制。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「表里之女神」以外的1只持有进行投掷硬币效果的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，自己场上的全部怪兽的攻击力直到回合结束时变成2倍。猜错的场合，自己场上的怪兽全部送去墓地，自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"猜硬币"
	e3:SetCategory(CATEGORY_COIN+CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
-- 定义检索筛选函数：筛选对象不是「表里之女神」自身、拥有进行投掷硬币效果、是怪兽且可以加入手卡的卡。
function s.thfilter(c)
	-- 筛选条件依次为：卡名不是本卡；拥有掷硬币效果；是怪兽；当前能加入手卡。
	return not c:IsCode(id) and c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_COIN)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①检索效果的目标函数：在发动时判断卡组是否存在符合条件的检索对象，若可以发动则预置从卡组检索加入手卡的处理信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己卡组中存在至少1张满足 s.thfilter 的怪兽，作为①的发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 预置操作信息：本次效果是从卡组把1只怪兽加入手卡（处理时再选定具体卡，因此目标暂为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①检索效果的处理：提示玩家选择检索的卡，从卡组选择1只符合条件的怪兽加入手卡，并让对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 实际从自己卡组中选出1张满足筛选条件的怪兽（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 把选中的卡加入其持有者的手卡，原因是效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 展示检索到的卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②起动效果的目标函数：发动条件为自己能抽1张卡（因为猜错后需要抽卡）；并预置本次操作包含掷硬币的信息。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己可以抽1张卡（保证猜错分支能够抽卡）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 预置操作信息：本次效果将进行掷硬币；后续处理根据猜中与否决定。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,0)
end
-- 定义攻击力翻倍对象的筛选函数：自己场上表侧表示且不免疫该效果的怪兽。
function s.atkfilter(c,e)
	return c:IsFaceup() and not c:IsImmuneToEffect(e)
end
-- ②效果处理：先让玩家宣言硬币正反面并掷1次硬币；若猜中，则自己场上全部表侧表示怪兽攻击力直到回合结束时变为当前攻击力的2倍；若猜错，则自己场上的怪兽全部送去墓地，然后自己抽1张。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择硬币的正反面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 玩家宣言硬币的正反面。
	local coin=Duel.AnnounceCoin(tp)
	-- 掷1次硬币，得到实际结果，用于和宣言比较是否猜中。
	local res=Duel.TossCoin(tp,1)
	if coin~=res then
		-- 猜中分支：获取自己场上满足攻击力翻倍条件（表侧表示且不免疫该效果）的全部怪兽。
		local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil,e)
		-- 遍历这些怪兽，逐一赋予攻击力翻倍的效果。
		for tc in aux.Next(g) do
			-- 猜中的场合，自己场上的全部怪兽的攻击力直到回合结束时变成2倍。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(tc:GetAttack()*2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	else
		-- 猜错分支：获取自己场上的全部怪兽（不取对象，处理时决定）。
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
		-- 若自己场上没有怪兽，或送去墓地的处理没有成功，则直接结束处理（不会抽卡）。
		if g:GetCount()==0 or Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
		-- 统计刚才因效果实际被送去墓地且仍在墓地的怪兽数；若为0则不抽卡。
		local oc=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
		if oc==0 then return end
		-- 猜错后，自己抽1张卡（原因：效果）。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
