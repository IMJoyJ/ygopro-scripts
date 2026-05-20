--月光舞香姫
-- 效果：
-- 「月光」怪兽×2
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。从卡组把1张「月华香」加入手卡。
-- ②：以自己场上1张其他的「月光」卡为对象才能发动。那张卡回到手卡·额外卡组。那之后，可以从手卡把1只「月光」怪兽特殊召唤。
-- ③：把墓地的这张卡除外才能发动。这个回合中，对方场上的怪兽的攻击力下降自身的原本守备力数值。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合召唤手续、①效果（融合召唤成功时检索「月华香」）、②效果（弹回场上「月光」卡并特召手牌「月光」怪兽）、③效果（墓地除外降低对方怪兽攻击力）
function s.initial_effect(c)
	-- 建立卡片关联，表明这张卡的效果中记载了「月华香」的卡名
	aux.AddCodeList(c,48444114)
	-- 设置融合召唤手续，需要2只「月光」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xdf),2,true)
	c:EnableReviveLimit()
	-- ①：这张卡融合召唤的场合才能发动。从卡组把1张「月华香」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1张其他的「月光」卡为对象才能发动。那张卡回到手卡·额外卡组。那之后，可以从手卡把1只「月光」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.bstg)
	e2:SetOperation(s.bsop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外才能发动。这个回合中，对方场上的怪兽的攻击力下降自身的原本守备力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	-- 设置效果③的发动代价为将墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：这张卡是通过融合召唤方式特殊召唤成功的
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果①的检索过滤条件：卡名为「月华香」且能加入手牌
function s.thfilter(c)
	return c:IsCode(48444114) and c:IsAbleToHand()
end
-- 效果①的发动准备：检查卡组是否存在「月华香」，并设置将卡加入手牌的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件（「月华香」）的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示将从卡组把1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组选择1张「月华香」加入手牌，并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件（「月华香」）的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的对象过滤条件：自己场上表侧表示的「月光」卡，且能回到手牌或额外卡组
function s.bfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xdf) and (c:IsAbleToHand() or c:IsAbleToExtra())
end
-- 效果②的发动准备：选择自己场上1张其他的「月光」卡为对象，并根据该卡类型设置回手牌或回额外卡组的操作信息
function s.bstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.bfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查自己场上是否存在除自身以外、满足过滤条件的「月光」卡
	if chk==0 then return Duel.IsExistingTarget(s.bfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)  --"请选择"
	-- 让玩家选择1张除自身以外的、满足过滤条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,s.bfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	local tc=g:GetFirst()
	if tc:IsAbleToExtra() then
		-- 若对象是融合/连接等额外怪兽，设置将其送回额外卡组的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	else
		-- 若对象是主卡组卡片，设置将其送回手牌的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
-- 效果②后续特召的过滤条件：手牌中的「月光」怪兽，且能被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xdf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的效果处理：使作为对象的卡回到手牌或额外卡组，若成功，则可以从手牌特召1只「月光」怪兽
function s.bsop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果关联的对象卡片
	local tg=Duel.GetTargetsRelateToChain()
	-- 如果对象卡片存在，且成功将其送回手牌或额外卡组
	if tg:GetCount()>0 and Duel.SendtoHand(tg,nil,REASON_EFFECT)>0
		and tg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND+LOCATION_EXTRA) then
		-- 获取手牌中所有满足特召条件的「月光」怪兽
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 如果手牌有可特召怪兽、怪兽区域有空位，且玩家选择进行特殊召唤
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤处理与前面的回手牌处理不视为同时进行（会造成错时点）
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			if tg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
				-- 洗切玩家的手牌
				Duel.ShuffleHand(tp)
			end
			-- 将选择的怪兽以表侧表示特殊召唤到自己的场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 效果③的效果处理：注册一个持续到回合结束的全局效果，使对方场上怪兽的攻击力下降
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合中，对方场上的怪兽的攻击力下降自身的原本守备力数值。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.atkval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将降低攻击力的效果注册给玩家，使其在场上生效
	Duel.RegisterEffect(e1,tp)
end
-- 计算攻击力下降数值的函数，返回该怪兽原本守备力的负值
function s.atkval(e,c)
	return -c:GetBaseDefense()
end
