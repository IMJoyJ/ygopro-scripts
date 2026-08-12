--ライトロード・アテナ ミネルバ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。把最多有那些作为同调素材的「光道」怪兽数量的「光道」怪兽从卡组送去墓地（相同种族最多1只）。
-- ②：自己场上的「光道」怪兽不能用效果除外。
-- ③：从自己墓地把最多4只「光道」怪兽除外才能发动。把除外数量的卡从自己卡组上面送去墓地。
local s,id,o=GetID()
-- 初始化效果，设置同调召唤程序、启用复活限制，并注册三个效果
function s.initial_effect(c)
	-- 为该卡添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为同调素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。把最多有那些作为同调素材的「光道」怪兽数量的「光道」怪兽从卡组送去墓地（相同种族最多1只）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从卡组送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：自己场上的「光道」怪兽不能用效果除外
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(s.efilter)
	c:RegisterEffect(e2)
	-- ③：从自己墓地把最多4只「光道」怪兽除外才能发动。把除外数量的卡从自己卡组上面送去墓地
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DECKDES)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCost(s.recost)
	e4:SetTarget(s.retg)
	e4:SetOperation(s.reop)
	c:RegisterEffect(e4)
end
-- 判断是否为同调召唤
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足「光道」种族、怪兽类型且能送去墓地的卡
function s.tgfilter(c)
	return c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 设置效果目标，检查是否满足发动条件并设置操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查是否满足发动条件：同调素材中「光道」怪兽数量大于0且卡组存在满足条件的卡
	if chk==0 then return e:GetHandler():GetMaterial():FilterCount(Card.IsSetCard,nil,0x38)>0 and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end
-- 选择满足条件的卡组卡片，确保种族不重复
function s.fselect(g)
	return g:GetClassCount(Card.GetRace)==g:GetCount()
end
-- 执行效果，从卡组选择满足条件的卡并送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local mc=e:GetHandler():GetMaterial():FilterCount(Card.IsSetCard,nil,0x38)
	-- 获取满足条件的卡组卡片
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and mc>0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(g:SelectSubGroup(tp,s.fselect,false,1,mc),REASON_EFFECT)
	end
end
-- 过滤满足条件的场上怪兽，判断是否为「光道」种族且处于正面表示状态，并由效果原因除外
function s.efilter(e,c,rp,r,re)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x38) and c:IsFaceup()
		and r&REASON_EFFECT>0 and r&REASON_REDIRECT==0
end
-- 过滤满足「光道」种族、怪兽类型且能作为除外费用的卡
function s.refilter(c)
	return c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 设置发动费用，标记为已支付费用
function s.recost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 设置效果目标，检查是否满足发动条件并选择要除外的卡
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家卡组中卡的数量
	local dc=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查是否满足发动条件：玩家可以丢弃卡组顶部至少1张卡、墓地存在满足条件的卡且卡组不为空
		return Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.IsExistingMatchingCard(s.refilter,tp,LOCATION_GRAVE,0,1,nil) and dc>0
	end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的墓地卡片并除外
	local cg=Duel.SelectMatchingCard(tp,s.refilter,tp,LOCATION_GRAVE,0,1,math.min(dc,4),nil)
	e:SetLabel(0,cg:GetCount())
	-- 将选择的卡除外作为费用
	Duel.Remove(cg,POS_FACEUP,REASON_COST)
	-- 设置操作信息，表示将从卡组丢弃相应数量的卡
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,cg:GetCount())
end
-- 执行效果，将卡组顶部相应数量的卡丢弃
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	local label,count=e:GetLabel()
	-- 将卡组顶部指定数量的卡丢弃
	Duel.DiscardDeck(tp,count,REASON_EFFECT)
end
