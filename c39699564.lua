--速炎星－タイヒョウ
-- 效果：
-- 这张卡召唤·特殊召唤成功的回合的主要阶段时，把自己场上1只名字带有「炎星」的怪兽解放才能发动。从卡组选1张名字带有「炎舞」的魔法·陷阱卡在自己场上盖放。「速炎星-戴豹」的效果1回合只能使用1次。
function c39699564.initial_effect(c)
	-- 效果原文内容：这张卡召唤·特殊召唤成功的回合的主要阶段时，把自己场上1只名字带有「炎星」的怪兽解放才能发动。从卡组选1张名字带有「炎舞」的魔法·陷阱卡在自己场上盖放。「速炎星-戴豹」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39699564,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,39699564)
	e1:SetCondition(c39699564.setcon)
	e1:SetCost(c39699564.setcost)
	e1:SetTarget(c39699564.settg)
	e1:SetOperation(c39699564.setop)
	c:RegisterEffect(e1)
	-- 效果原文内容：这张卡召唤·特殊召唤成功的回合的主要阶段时，把自己场上1只名字带有「炎星」的怪兽解放才能发动。从卡组选1张名字带有「炎舞」的魔法·陷阱卡在自己场上盖放。「速炎星-戴豹」的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c39699564.sumop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 效果作用：判断当前回合是否为该卡召唤或特殊召唤成功的回合
function c39699564.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(39699564)>0
end
-- 效果作用：支付效果代价，解放1只名字带有「炎星」的怪兽
function c39699564.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查场上是否存在至少1只名字带有「炎星」的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x79) end
	-- 效果作用：选择1只名字带有「炎星」的可解放怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x79)
	-- 效果作用：将选中的怪兽解放作为效果的代价
	Duel.Release(g,REASON_COST)
end
-- 效果作用：定义可盖放的卡片过滤条件，即名字带有「炎舞」的魔法或陷阱卡
function c39699564.filter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果作用：设置效果的发动条件，检查卡组中是否存在满足条件的卡片
function c39699564.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查卡组中是否存在至少1张名字带有「炎舞」的魔法或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c39699564.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果作用：执行效果，选择并盖放1张名字带有「炎舞」的魔法或陷阱卡
function c39699564.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：向玩家提示选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 效果作用：从卡组中选择1张名字带有「炎舞」的魔法或陷阱卡
	local g=Duel.SelectMatchingCard(tp,c39699564.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 效果作用：将选中的卡片在自己场上盖放
		Duel.SSet(tp,g)
	end
end
-- 效果作用：在通常召唤或特殊召唤成功时，为该卡注册一个标记，表示其在本回合可以发动效果
function c39699564.sumop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(39699564,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
