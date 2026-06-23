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
-- 初始化效果，启用复活限制并设置融合召唤条件
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用满足条件的怪兽作为素材进行融合召唤
	aux.AddFusionProcFunRep2(c,s.ffilter,2,127,true)
	-- 创建诱发效果，用于在特殊召唤成功时发动
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
	-- 创建素材检查效果，用于记录融合素材的属性种类数量
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 过滤函数，判断怪兽是否为「灵使」或「凭依装着」系列
function s.ffilter(c,fc)
	return c:IsFusionSetCard(0xbf,0x10c0)
end
-- 检查效果，获取融合素材中不同属性的数量并记录到标签中
function s.valcheck(e,c)
	local ct=c:GetMaterial():GetClassCount(Card.GetOriginalAttribute)
	e:GetLabelObject():SetLabel(ct)
end
-- 条件函数，判断此卡是否为融合召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 目标函数，检查是否可以发动效果（即是否有可选效果）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	if chk==0 then return ct>0 end
end
-- 检索过滤函数，筛选「凭依」魔法或陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0xc0) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 特殊召唤过滤函数，筛选魔法师族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数，根据选择的效果执行对应操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if ct<=0 then return end
	if ct>4 then ct=4 end
	for i=1,ct do
		local b1=c:IsRelateToChain() and c:IsFaceup() and c:IsType(TYPE_MONSTER)
		-- 判断卡组中是否存在「凭依」魔法或陷阱卡
		local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 判断场上是否存在可送回手牌的卡
		local b3=Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 判断墓地中是否存在可特殊召唤的魔法师族怪兽且场上存在空位
		local b4=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		local b5=i>1
		if not b1 and not b2 and not b3 and not b4 then break end
		-- 选择效果选项，允许玩家从多个效果中选择一个
		local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"攻击力上升"
			{b2,aux.Stringid(id,2),2},  --"检索"
			{b3,aux.Stringid(id,3),3},  --"回到手卡"
			{b4,aux.Stringid(id,4),4},  --"特殊召唤"
			{b5,aux.Stringid(id,5),5})  --"结束"
		if i>1 and op~=5 then
			-- 中断当前效果处理，使后续效果视为错时点处理
			Duel.BreakEffect()
		end
		if op==1 then
			-- 攻击力上升800的效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			e1:SetValue(800)
			c:RegisterEffect(e1)
		elseif op==2 then
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 选择满足条件的「凭依」魔法或陷阱卡
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if g:GetCount()>0 then
				-- 将选中的卡送入手牌
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 确认对方查看所选的卡
				Duel.ConfirmCards(1-tp,g)
			end
		elseif op==3 then
			-- 提示玩家选择要返回手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			-- 选择满足条件的场上卡
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if g:GetCount()>0 then
				-- 显示被选为对象的动画效果
				Duel.HintSelection(g)
				-- 将选中的卡送回手牌
				Duel.SendtoHand(g,nil,REASON_EFFECT)
			end
		elseif op==4 then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择满足条件的墓地魔法师族怪兽
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选中的怪兽特殊召唤到场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		elseif op==5 then
			break
		end
	end
end
