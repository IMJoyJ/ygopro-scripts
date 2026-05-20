--エクソシスター・カルマエル
-- 效果：
-- 4星「救祓少女」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。这个回合的结束阶段，自己的卡组·墓地·除外状态的1张「救祓少女」魔法·陷阱卡在自己场上盖放。
-- ②：对方把怪兽的效果·通常魔法·通常陷阱卡发动时才能发动。这张卡的超量素材全部取除，那个效果变成「从对方墓地把1张卡加入对方手卡」。
local s,id,o=GetID()
-- 初始化卡片效果，注册XYZ召唤手续、①效果（超量召唤成功时在结束阶段盖放魔陷）和②效果（对方发动效果时去除全部素材改变其效果）
function s.initial_effect(c)
	-- 添加XYZ召唤手续：4星「救祓少女」怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x172),4,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤的场合才能发动。这个回合的结束阶段，自己的卡组·墓地·除外状态的1张「救祓少女」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放魔陷"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.recon)
	e1:SetTarget(s.retg)
	e1:SetOperation(s.reop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽的效果·通常魔法·通常陷阱卡发动时才能发动。这张卡的超量素材全部取除，那个效果变成「从对方墓地把1张卡加入对方手卡」。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变效果"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.chcon)
	e2:SetTarget(s.chtg)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)
end
-- 检查此卡是否通过XYZ召唤的方式特殊召唤，作为①效果的发动条件
function s.recon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- ①效果的发动准备，仅做基本合法性检查并向对方提示发动
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ①效果的处理：注册一个在结束阶段触发的延迟效果，用于盖放魔陷
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡超量召唤的场合才能发动。这个回合的结束阶段，自己的卡组·墓地·除外状态的1张「救祓少女」魔法·陷阱卡在自己场上盖放。②：对方把怪兽的效果·通常魔法·通常陷阱卡发动时才能发动。这张卡的超量素材全部取除，那个效果变成「从对方墓地把1张卡加入对方手卡」。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.setop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该全局延迟效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：卡组、墓地、除外状态的「救祓少女」魔法·陷阱卡，且在场上可以盖放
function s.setfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x172) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 结束阶段延迟效果的具体处理：从卡组、墓地、除外状态选择1张「救祓少女」魔法·陷阱卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动该卡的效果（显示卡片动画）
	Duel.Hint(HINT_CARD,0,id)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 检索并让玩家从卡组、墓地、除外状态选择1张满足条件的「救祓少女」魔法·陷阱卡（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
-- ②效果的发动条件：对方发动了怪兽的效果、或者通常魔法·通常陷阱卡的发动
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and (re:IsActiveType(TYPE_MONSTER)
		or (re:GetActiveType()==TYPE_SPELL or re:GetActiveType()==TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- ②效果的发动准备：检查自身是否有超量素材，且对方墓地是否有可以加入手牌的卡
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方墓地是否存在可以加入手牌的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,rp,0,LOCATION_GRAVE,1,nil,REASON_EFFECT)
		and e:GetHandler():GetOverlayCount()>0 end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ②效果的处理：将这张卡的超量素材全部送去墓地，并将对方发动的效果替换为「从对方墓地把1张卡加入对方手卡」
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsType(TYPE_MONSTER) then
		local og=c:GetOverlayGroup()
		if og:GetCount()==0 then return end
		-- 将这张卡的所有超量素材送去墓地
		Duel.SendtoGrave(og,REASON_EFFECT)
		local g=Group.CreateGroup()
		-- 清空当前连锁的效果对象
		Duel.ChangeTargetCard(ev,g)
		-- 将当前连锁的效果处理函数替换为指定的替换效果处理函数（s.repop）
		Duel.ChangeChainOperation(ev,s.repop)
	end
end
-- 替换后的效果处理：让对方玩家从其墓地选择1张卡加入其手牌
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示对方玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让对方玩家从其墓地选择1张可以加入手牌的卡（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToHand),tp,0,LOCATION_GRAVE,1,1,nil)
	if g:GetCount()>0 then
		-- 选中卡片的视觉提示
		Duel.HintSelection(g)
		-- 将选中的卡加入持有者（对方）的手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
