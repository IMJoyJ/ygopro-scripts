--E-HERO ヘル・ライダー
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 记录这张卡在效果中记载了「暗黑融合」和「超融合」的卡名
	aux.AddCodeList(c,94820406,48130397)
	-- ①：这张卡召唤・特殊召唤成功的场合才能发动。从卡组・墓地把1张「暗黑融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡和4只怪兽除外才能发动。从卡组把1张「超融合」盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.setcost)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡名是「暗黑融合」且能加入手牌的卡
function s.thfilter(c)
	return c:IsCode(94820406) and c:IsAbleToHand()
end
-- 效果1（检索/回收「暗黑融合」）的发动准备与合法性检查
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地是否存在可以加入手牌的「暗黑融合」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理信息：从卡组或墓地将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果1（检索/回收「暗黑融合」）的效果处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张满足条件的「暗黑融合」（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：墓地中可以作为发动成本除外的怪兽
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果2的发动成本（Cost）检查与处理函数
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能将墓地的这张卡自身除外作为发动成本
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
		-- 检查墓地中是否存在除这张卡以外的4只怪兽可以除外
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,4,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从墓地选择4只除这张卡以外的怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,4,4,e:GetHandler())
	-- 将选中的4只怪兽表侧表示除外作为发动成本
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 将墓地的这张卡自身除外作为发动成本
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
end
-- 过滤条件：卡名是「超融合」且可以盖放的魔法·陷阱卡
function s.stfilter(c)
	return c:IsCode(48130397) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果2（盖放「超融合」）的发动准备与合法性检查
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在可以盖放的「超融合」
		and Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果2（盖放「超融合」并施加特殊召唤限制）的效果处理函数
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检查魔法与陷阱区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 让玩家从卡组选择1张「超融合」
		local g=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			-- 将选中的「超融合」在自己场上盖放
			Duel.SSet(tp,g)
		end
	end
	-- 这个效果的发动后，直到对方回合结束时自己不是「HERO」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 注册限制玩家特殊召唤非「HERO」怪兽的全局效果
	Duel.RegisterEffect(e1,tp)
	-- 这个效果的发动后，直到对方回合结束时自己不是「HERO」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(72043279)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 注册用于在客户端显示特殊召唤限制的提示图标效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制不能特殊召唤非「HERO」怪兽的过滤函数
function s.splimit(e,c)
	return not c:IsSetCard(0x8)
end
