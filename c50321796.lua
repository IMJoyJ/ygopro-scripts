--氷結界の龍 ブリューナク
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的效果1回合只能使用1次。
-- ①：把手卡任意数量丢弃去墓地，以丢弃数量的对方场上的卡为对象才能发动。那些卡回到手卡。
function c50321796.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整怪兽＋1只以上调整以外的怪兽作为素材才能同调召唤。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的效果1回合只能使用1次。①：把手卡任意数量丢弃去墓地，以丢弃数量的对方场上的卡为对象才能发动。那些卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50321796,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,50321796)
	e1:SetCost(c50321796.cost)
	e1:SetTarget(c50321796.target)
	e1:SetOperation(c50321796.operation)
	c:RegisterEffect(e1)
end
-- 判定一张卡能否作为本效果的COST：手牌中的卡必须能被丢弃去墓地；墓地中的卡必须同时满足“效果持有者卡名为冰结界字段”“该卡可以除外”且“该卡受到卡号18319762的效果允许”时，才能代替手牌作为COST除外。
function c50321796.costfilter(c,e,tp)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsDiscardable() and c:IsAbleToGraveAsCost()
	else
		return e:GetHandler():IsSetCard(0x2f) and c:IsAbleToRemove() and c:IsHasEffect(18319762,tp)
	end
end
-- 选择COST组的过滤条件：所选的卡中来自墓地的卡数量不超过1张，即只能最多使用1张墓地卡代替手牌。
function c50321796.fselect(g)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=1
end
-- COST结算：先判断存在可丢弃的卡；计算对方场上可回手牌数量作为丢弃张数上限；取得全部可丢弃候选；弹出丢弃选择提示；让玩家选择1至上限张满足条件的卡，且墓地来源最多1张；将选择的张数存入效果标签供target使用；若选择了墓地卡，则发动其代替效果并除外该卡；其余手牌作为COST丢弃。
function c50321796.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- COST可发动的检查：己方手牌或墓地中是否存在至少1张满足costfilter的卡可以作为COST。
	if chk==0 then return Duel.IsExistingMatchingCard(c50321796.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 统计对方场上能以本效果返回手牌的卡数量，作为本次最多可丢弃的手牌数（丢弃数量不能超过可对象数）。
	local rt=Duel.GetTargetCount(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	-- 取得己方手牌与墓地中所有可作为COST的候选卡集合，供后续选择。
	local g=Duel.GetMatchingGroup(c50321796.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	-- 向玩家显示“请选择要丢弃的手牌”的选择提示，用于COST选卡界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local cg=g:SelectSubGroup(tp,c50321796.fselect,false,1,rt)
	e:SetLabel(cg:GetCount())
	local tc=cg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
	if tc then
		local te=tc:IsHasEffect(18319762,tp)
		te:UseCountLimit(tp)
		-- 将选择作为COST的墓地卡以表侧表示除外，原因是效果代替（不算作丢弃去墓地）。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		cg:RemoveCard(tc)
	end
	-- 将选中的手牌作为代价丢弃去墓地（COST+DISCARD）。
	Duel.SendtoGrave(cg,REASON_COST+REASON_DISCARD)
end
-- 目标选择处理：确认可取对象；读取COST丢弃数量作为需选对象数；提示玩家选择对应数量的对方场上可回手牌；将所选卡设为效果对象并登记回手牌信息。
function c50321796.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 目标合法性检查：确认对方场上存在至少1张可以成为对象并返回手牌的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetLabel()
	-- 显示“请选择要返回手牌的卡”的选择提示，用于选择目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家从对方场上选择ct张可回手牌的卡作为效果对象（ct等于丢弃数量）。
	local tg=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	-- 登记本连锁的操作信息：将对象卡tg以CATEGORY_TOHAND、数量ct写入，使系统能检测回手牌效果。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,ct,0,0)
end
-- 效果处理：取得连锁对象，筛选仍与该效果关联的对象，将它们返回持有者手牌。
function c50321796.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的、在目标选择阶段被选为对象的卡组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if rg:GetCount()>0 then
		-- 将仍与效果关联的对象卡因本效果返回持有者手牌。
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
	end
end
