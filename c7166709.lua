--鉄絃の犠打職人
-- 效果：
-- 这张卡在手卡·墓地存在的场合：可以把手卡1只5星以上的怪兽给对方出示，从以下效果选择1个发动（「钢弦祭他手」的以下效果1回合各能选择1次），发动后，这个回合中自己没有把出示怪兽或者原本卡名和那只怪兽相同的怪兽召唤的场合，结束阶段让自己失去1000基本分。
-- ●这张卡从手卡特殊召唤。
-- ●这张卡从自己墓地加入手卡。
-- ●从自己墓地把这张卡除外，从自己墓地把1只5星以上的怪兽加入手卡。
local s,id,o=GetID()
-- 创建三个效果，分别对应从手卡特殊召唤、从墓地加入手卡、从墓地除外并抽卡的效果
function s.initial_effect(c)
	-- 这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这张卡从自己墓地加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetDescription(aux.Stringid(id,2))  --"加入手卡"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 从自己墓地把这张卡除外，从自己墓地把1只5星以上的怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))  --"这张卡除外"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选手牌中等级5以上且未公开的怪兽
function s.cfilter(c)
	return c:IsLevelAbove(5) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 检查是否满足cost条件，并选择一张手牌中的5星以上怪兽给对方确认，然后洗切手牌并记录该怪兽的原始卡号
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足cost条件，即手牌中是否存在至少1张5星以上的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家提示“请选择给对方确认的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择一张手牌中的5星以上怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 确认对方能看到所选的怪兽
	Duel.ConfirmCards(1-tp,g)
	local tc=g:GetFirst()
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
	e:SetLabel(tc:GetOriginalCodeRule())
end
-- 判断特殊召唤的条件是否满足，即自己场上是否有空位且该卡能被特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的场地区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤操作，并注册两个持续效果用于判定是否触发惩罚效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将该卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 注册一个在召唤成功时触发的效果，用于记录是否召唤了与所出示怪兽同名的怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetLabel(e:GetLabel())
	e1:SetOperation(s.regop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 注册一个在结束阶段触发的效果，用于判定是否触发惩罚效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	e2:SetLabelObject(e1)
	-- 将效果e2注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 过滤函数，用于判断是否为指定玩家召唤且原始卡号与目标一致
function s.regfilter(c,tp,code)
	return c:IsSummonPlayer(tp) and c:IsOriginalCodeRule(code)
end
-- 当有怪兽被召唤时，检查是否召唤了与所出示怪兽同名的怪兽，若是则标记为已触发
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then return end
	if eg:IsExists(s.regfilter,1,nil,tp,e:GetLabel()) then
		e:SetLabel(0)
	end
end
-- 判定惩罚效果是否应该触发，即是否在结束阶段前未召唤过同名怪兽
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()~=0
end
-- 执行惩罚效果，使玩家失去1000基本分
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 使玩家失去1000基本分
	Duel.SetLP(tp,Duel.GetLP(tp)-1000)
end
-- 判断回手的条件是否满足，即该卡能否被送入手牌
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息为回手
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行回手操作，并注册两个持续效果用于判定是否触发惩罚效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查该卡是否与连锁相关且未受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将该卡送入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 确认对方能看到所送入手牌的卡
		Duel.ConfirmCards(1-tp,c)
	end
	-- 注册一个在召唤成功时触发的效果，用于记录是否召唤了与所出示怪兽同名的怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetLabel(e:GetLabel())
	e1:SetOperation(s.regop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 注册一个在结束阶段触发的效果，用于判定是否触发惩罚效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	e2:SetLabelObject(e1)
	-- 将效果e2注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 过滤函数，用于筛选墓地中等级5以上且能送入手牌的怪兽
function s.thfilter(c)
	return c:IsLevelAbove(5) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 判断第三个效果的发动条件是否满足，即墓地是否存在至少1张5星以上的怪兽且该卡能除外
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有满足条件的墓地怪兽可以被选中
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,c)
		and c:IsAbleToRemove() end
	-- 设置操作信息为将墓地中的怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	-- 设置操作信息为除外该卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end
-- 执行第三个效果的操作，先除外该卡再从墓地选择一张5星以上的怪兽送入手牌，并注册两个持续效果用于判定是否触发惩罚效果
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查该卡是否与连锁相关且未受王家长眠之谷影响且成功除外
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.Remove(c,0,REASON_EFFECT)~=0 then
		-- 向玩家提示“请选择要加入手牌的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从墓地中选择一张5星以上的怪兽送入手牌
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽送入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方能看到所送入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
	-- 注册一个在召唤成功时触发的效果，用于记录是否召唤了与所出示怪兽同名的怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetLabel(e:GetLabel())
	e1:SetOperation(s.regop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 注册一个在结束阶段触发的效果，用于判定是否触发惩罚效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	e2:SetLabelObject(e1)
	-- 将效果e2注册给玩家
	Duel.RegisterEffect(e2,tp)
end
