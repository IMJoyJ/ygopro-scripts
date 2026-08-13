--大輪の霊使い
-- 效果：
-- 「灵使」、「凭依装着」怪兽×2只以上
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡融合召唤的场合才能发动。让最多有作为这张卡的融合素材的怪兽的原本属性种类数量的「从以下效果选1个，那个效果适用」处理重复（最多4次）。
-- ●这张卡的攻击力上升800。
-- ●从卡组把1张「凭依」魔法·陷阱卡加入手卡。
-- ●场上1张卡回到手卡。
-- ●从自己墓地把1只魔法师族怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化怪兽效果：允许融合召唤并设置融合手续，注册融合召唤成功时发动的诱发效果，以及记录素材原本属性种类数的素材检查效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续：以2只以上（最多127只）满足s.ffilter条件的怪兽作为融合素材。
	aux.AddFusionProcFunRep2(c,s.ffilter,2,127,true)
	-- ①：这张卡融合召唤的场合才能发动。让最多有作为这张卡的融合素材的怪兽的原本属性种类数量的「从以下效果选1个，那个效果适用」处理重复（最多4次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 作为这张卡的融合素材的怪兽的原本属性种类数量。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 定义融合素材条件：怪兽属于「灵使」（0xbf）或「凭依装着」（0x10c0）字段。
function s.ffilter(c,fc)
	return c:IsFusionSetCard(0xbf,0x10c0)
end
-- 素材检查时计算所用融合素材的原本属性种类数，并存入触发效果e1的标签中，供效果处理时确定重复次数。
function s.valcheck(e,c)
	local ct=c:GetMaterial():GetClassCount(Card.GetOriginalAttribute)
	e:GetLabelObject():SetLabel(ct)
end
-- 触发条件：这张卡以融合召唤方式成功特殊召唤。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果发动条件：记录到的素材原本属性种类数大于0时允许发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	if chk==0 then return ct>0 end
end
-- 检索过滤：卡片为「凭依」字段的魔法·陷阱卡，且能够加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0xc0) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 特招过滤：卡片为魔法师族怪兽，且能够通过当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：按素材原本属性种类数（最多4次）循环，每次让玩家从攻击力上升800、检索「凭依」魔陷、场上1卡回手、墓地特招魔法师族中选择1项；若某次全部不可选则中断，若后续仍选择选项则用BreakEffect错开处理。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if ct<=0 then return end
	if ct>4 then ct=4 end
	for i=1,ct do
		local b1=c:IsRelateToChain() and c:IsFaceup() and c:IsType(TYPE_MONSTER)
		-- 检查卡组中是否存在满足s.thfilter的「凭依」魔法·陷阱卡。
		local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查场上（双方）是否存在可以加入手卡的卡。
		local b3=Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 检查自己墓地是否存在不受王家长眠之谷影响且可特招的魔法师族怪兽，并确认自己主要怪兽区有空位。
		local b4=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		local b5=i>1
		if not b1 and not b2 and not b3 and not b4 then break end
		-- 进入选项选择：由玩家从当前可选效果中选1项，赋值给op。
		local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"攻击力上升"
			{b2,aux.Stringid(id,2),2},  --"检索"
			{b3,aux.Stringid(id,3),3},  --"回到手卡"
			{b4,aux.Stringid(id,4),4},  --"特殊召唤"
			{b5,aux.Stringid(id,5),5})  --"结束"
		if i>1 and op~=5 then
			-- 中断当前效果处理，使后续处理作为独立连锁，避免错过时点。
			Duel.BreakEffect()
		end
		if op==1 then
			-- ●这张卡的攻击力上升800。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			e1:SetValue(800)
			c:RegisterEffect(e1)
		elseif op==2 then
			-- 提示玩家选择要加入手卡的卡，并设置选择消息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 从卡组选择1张满足s.thfilter的「凭依」魔法·陷阱卡。
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if g:GetCount()>0 then
				-- 将选中的卡加入其持有者的手卡。
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 向对方展示检索加入手卡的卡。
				Duel.ConfirmCards(1-tp,g)
			end
		elseif op==3 then
			-- 提示玩家选择要返回手卡的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			-- 从场上（双方）选择1张可以加入手卡的卡。
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if g:GetCount()>0 then
				-- 显示选择动画并记录选择对象。
				Duel.HintSelection(g)
				-- 将选择的卡返回手卡。
				Duel.SendtoHand(g,nil,REASON_EFFECT)
			end
		elseif op==4 then
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从自己墓地选择1只可特招的魔法师族怪兽（排除王家长眠之谷影响）。
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选择的怪兽表侧攻击表示特殊召唤到自己场上。
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		elseif op==5 then
			break
		end
	end
end
