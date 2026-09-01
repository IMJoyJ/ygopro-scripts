--Lunalight Scarlet Tiger
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 记录卡名「融合」
	aux.AddCodeList(c,24094653)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上的「月光」怪兽的效果发动时才能发动。这张卡从手卡特殊召唤。对方在这一回合有把效果发动的场合，可以再从自己的卡组·墓地把1张「融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合才能发动。从自己的墓地·额外卡组把5星以外的1只「月光」怪兽特殊召唤。这个效果特殊召唤的怪兽不能把效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- 添加自定义连锁活动计数器
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,aux.FALSE)
end
-- ①效果的发动条件：自己场上的「月光」怪兽的效果发动时
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0xdf)
end
-- ①效果的目标：检查怪兽区空位并特殊召唤自身
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤卡名为「融合」且可加入手牌的卡
function s.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- ①效果的处理：特殊召唤自身，满足条件时可将「融合」加入手牌
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 特殊召唤自身到场上
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查对方本回合是否发动过效果
		and Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
		-- 检查卡组或墓地是否存在「融合」
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		-- 玩家选择是否将「融合」加入手牌
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 动作连接，前后效果不同时处理
		Duel.BreakEffect()
		-- 提示选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组或墓地选择1张「融合」
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件：被效果送去墓地
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤墓地或额外卡组5星以外的「月光」怪兽
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and not c:IsLevel(5)
		and c:IsSetCard(0xdf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		-- 墓地存在时检查怪兽区空位
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 额外卡组存在时检查额外怪兽区空位
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- ②效果的目标：检查是否存在可特殊召唤的「月光」怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地或额外卡组是否有可特招的「月光」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- ②效果的处理：从墓地或额外卡组特殊召唤并赋予不能发动效果的限制
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只5星以外的「月光」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	-- 将选择的怪兽特殊召唤
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local tc=g:GetFirst()
		-- 这个效果特殊召唤的怪兽不能把效果发动
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
	end
end
