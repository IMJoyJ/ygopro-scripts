--月光金獅子
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「月光金狮子」以外的1只「月光」怪兽加入手卡。那之后，选自己1张手卡丢弃。
-- ②：这张卡在怪兽区域存在的状态，「月光」怪兽被送去自己墓地的场合，以那之内的1只为对象才能发动（伤害步骤也能发动）。那只怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①召唤·特殊召唤时检索并丢弃手牌的效果，以及②怪兽区域存在时「月光」怪兽送墓回收的效果。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「月光金狮子」以外的1只「月光」怪兽加入手卡。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
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
	-- 为单张卡片注册一个合并的延迟送墓事件监听器，用于处理多张「月光」怪兽同时送墓时的触发时点。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_TO_GRAVE)
	-- ②：这张卡在怪兽区域存在的状态，「月光」怪兽被送去自己墓地的场合，以那之内的1只为对象才能发动（伤害步骤也能发动）。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回收"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(custom_code)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon2)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：除「月光金狮子」以外的「月光」怪兽。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0xdf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动准备，检查卡组中是否存在可检索的卡，并设置检索和丢弃手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「月光」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置当前连锁的操作信息为：丢弃1张手牌。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果①的效果处理，从卡组将1只「月光」怪兽加入手牌，之后选择1张手牌丢弃。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张满足条件的「月光」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			-- 提示玩家选择要丢弃的手牌。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			-- 玩家选择1张可以丢弃的手牌。
			local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
			-- 中断当前效果处理，使后续的丢弃手牌处理与加入手牌不视为同时处理。
			Duel.BreakEffect()
			-- 洗切玩家的手牌。
			Duel.ShuffleHand(tp)
			-- 将选择的手牌因效果丢弃送去墓地。
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
-- 过滤条件：原本持有者是自己且属于「月光」系列的怪兽。
function s.cfilter(c,tp)
	return c:GetOwner()==tp and c:IsSetCard(0xdf) and c:IsType(TYPE_MONSTER)
end
-- 效果②的发动条件：送去墓地的卡中存在自己的「月光」怪兽，且不包含此卡自身。
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 过滤条件：在墓地中、可以成为效果对象且能加入手牌的卡。
function s.tgfilter(c,e)
	return c:IsLocation(LOCATION_GRAVE) and c:IsCanBeEffectTarget(e) and c:IsAbleToHand()
end
-- 效果②的发动准备，筛选送去自己墓地的「月光」怪兽并选择其中1只作为对象，设置回收的操作信息。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=eg:Filter(s.cfilter,nil,tp):Filter(s.tgfilter,nil,e)
	if chkc then return mg:IsContains(chkc) and s.tgfilter(chkc,e) end
	if chk==0 then return mg:GetCount()>0 end
	local g=mg
	if mg:GetCount()>1 then
		-- 提示玩家选择效果的对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		g=mg:Select(tp,1,1,nil)
	end
	-- 将选择的怪兽设置为当前连锁的效果对象。
	Duel.SetTargetCard(g)
	-- 设置当前连锁的操作信息为：将指定的对象怪兽加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理，将作为对象的墓地怪兽加入手牌。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与连锁相关、是怪兽卡，且不受「王家长眠之谷」的影响。
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
