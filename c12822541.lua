--DDリリス
-- 效果：
-- 「DD 莉莉丝」的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，可以从以下效果选择1个发动。
-- ●以自己墓地1只「DD」怪兽为对象才能发动。那只怪兽加入手卡。
-- ●从自己的额外卡组把1只表侧表示的「DD」灵摆怪兽加入手卡。
function c12822541.initial_effect(c)
	-- 「DD 莉莉丝」的效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功的场合，可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,12822541)
	e1:SetTarget(c12822541.thtg)
	e1:SetOperation(c12822541.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断墓地的卡是否为「DD」怪兽、属于怪兽卡并且能加入手卡，用于检索墓地可回手的对象。
function c12822541.filter1(c)
	return c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤函数：判断额外卡组的卡是否为表侧表示的「DD」灵摆怪兽并且能加入手卡，用于检索额外卡组可回手的对象。
function c12822541.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 效果发动时的目标处理：先检查两个可选分支是否各自有满足条件的卡；若双方都有则弹出选项让玩家选择，若只有一方有则自动确定分支；随后根据选择的选项设定对应的取对象/不取对象检索范围，并写入操作信息。
function c12822541.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12822541.filter1(chkc) end
	-- 检查自己墓地是否存在至少1只满足filter1条件的「DD」怪兽，作为可选分支“以自己墓地1只「DD」怪兽为对象”是否能发动的依据。
	local b1=Duel.IsExistingTarget(c12822541.filter1,tp,LOCATION_GRAVE,0,1,nil)
	-- 检查自己额外卡组是否存在至少1张满足filter2条件的表侧表示「DD」灵摆怪兽，作为可选分支“从自己的额外卡组把1只表侧表示的「DD」灵摆怪兽加入手卡”是否能发动的依据。
	local b2=Duel.IsExistingMatchingCard(c12822541.filter2,tp,LOCATION_EXTRA,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	-- 当两个分支都存在合法目标时，让玩家选择具体发动哪个效果：选项0对应“自己墓地1只「DD」怪兽加入手卡”，选项1对应“自己额外卡组1只「DD」灵摆怪兽加入手卡”。
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(12822541,0),aux.Stringid(12822541,1))  --"自己墓地1只「DD」怪兽加入手卡/自己额外卡组1只「DD」灵摆怪兽加入手卡"
	-- 当只有墓地分支有合法目标时，直接选择墓地回手效果（选项0），不弹出双选项菜单。
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(12822541,0))  --"自己墓地1只「DD」怪兽加入手卡"
	-- 当只有额外卡组分支有合法目标时，直接选择额外灵摆回手效果；Duel.SelectOption返回0后加1，使op=1，标记为第二个分支。
	else op=Duel.SelectOption(tp,aux.Stringid(12822541,1))+1 end  --"自己额外卡组1只「DD」灵摆怪兽加入手卡"
	e:SetLabel(op)
	if op==0 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		-- 向玩家发送“请选择要加入手牌的卡”的提示，用于墓地目标选择时的选择框。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择自己墓地1张满足filter1条件的「DD」怪兽作为效果对象（取对象），并记录该对象与当前连锁的关联。
		local g=Duel.SelectTarget(tp,c12822541.filter1,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 设置当前连锁的操作信息：确定要处理的效果分类为回手牌，目标为已选择的墓地怪兽g，数量1，使相关效果（如星尘龙、王家长眠之谷等）能正确检测。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	else
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		-- 设置当前连锁的操作信息：不取对象地从额外卡组将1张表侧「DD」灵摆怪兽加入手牌，因此目标不预先指定，只记录处理时预计从额外卡组选择1张卡。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
	end
end
-- 效果处理阶段：若此前选择的是墓地分支（op=0），则取得对象墓地怪兽并在确认其仍与效果关联后加入手牌；若选择的是额外分支（op=1），则从额外卡组选择1张满足条件的表侧「DD」灵摆怪兽并加入手牌。
function c12822541.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 取得效果发动时选择的墓地对象卡（取对象模式下唯一的对象）。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将取得的墓地怪兽加入持有者的手牌，移动原因是效果处理。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	else
		-- 向玩家发送“请选择要加入手牌的卡”的提示，用于额外卡组选择时的选择框。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己额外卡组选择1张满足filter2条件的表侧表示「DD」灵摆怪兽（此步骤在效果处理时进行，不取对象）。
		local g=Duel.SelectMatchingCard(tp,c12822541.filter2,tp,LOCATION_EXTRA,0,1,1,nil)
		if g:GetCount()>0 then
			-- 为选出的额外卡组怪兽显示被选为对象的动画，并记录该卡被选为对象（广义）。
			Duel.HintSelection(g)
			-- 将选出的额外卡组灵摆怪兽加入持有者的手牌，移动原因是效果处理。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
