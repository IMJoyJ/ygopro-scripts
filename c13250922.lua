--オオアリクイクイアリ
-- 效果：
-- 这张卡不能通常召唤。把自己场上2张魔法·陷阱卡送去墓地的场合才能特殊召唤。这张卡可以作为攻击的代替而把对方场上1张魔法·陷阱卡破坏。
function c13250922.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤（特殊召唤条件限制，效果外文本）
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上2张魔法·陷阱卡送去墓地的场合才能特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c13250922.spcon)
	e2:SetTarget(c13250922.sptg)
	e2:SetOperation(c13250922.spop)
	c:RegisterEffect(e2)
	-- 这张卡可以作为攻击的代替而把对方场上1张魔法·陷阱卡破坏
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13250922,0))  --"破坏"
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c13250922.descost)
	e3:SetTarget(c13250922.destg)
	e3:SetOperation(c13250922.desop)
	c:RegisterEffect(e3)
end
-- 筛选可作为特殊召唤cost的卡：必须是魔法·陷阱卡，且可以作为cost送去墓地
function c13250922.spfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤手续的条件判断：自己场上有2张可送墓的魔法·陷阱卡，且送墓后仍存在可用的怪兽区域空格，才能从手牌进行规则特殊召唤
function c13250922.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有可作为特殊召唤cost的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c13250922.spfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 检查从候选卡中能否选出2张，并保证送墓后自己场上仍有怪兽区域空格
	return g:CheckSubGroup(aux.mzctcheck,2,2,tp)
end
-- 特殊召唤手续的选择阶段：让玩家选择2张魔法·陷阱卡作为送墓cost，选择成功则保存并允许特殊召唤
function c13250922.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上可作为特殊召唤cost的魔法·陷阱卡，供后续选择
	local g=Duel.GetMatchingGroup(c13250922.spfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 提示玩家选择要送去墓地的卡（用于特殊召唤cost）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从候选中选出2张卡，并再度确认送墓后仍有怪兽区域空格可用
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的操作：将选中的2张魔法·陷阱卡送去墓地，完成特殊召唤的cost处理
function c13250922.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡以特殊召唤手续为原因送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 筛选条件：该卡是魔法·陷阱卡（用于破坏效果的对象选择）
function c13250922.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的发动cost：本回合该卡尚未攻击宣言，发动后给自己附加不能攻击的誓约效果，作为“攻击的代替”的代价
function c13250922.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 作为攻击的代替（发动后本回合不能再攻击）
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 破坏效果的发动条件和目标选择：取对象选择对方场上1张魔法·陷阱卡，并登记破坏操作信息
function c13250922.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c13250922.filter(chkc) end
	-- 发动时判定：对方场上是否存在1张可作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c13250922.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法·陷阱卡作为效果对象，并设为当前连锁的对象
	local g=Duel.SelectTarget(tp,c13250922.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置本连锁的破坏操作信息，供星尘龙等效果进行连锁检测
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果处理：若对象仍与该效果关联，则将其破坏
function c13250922.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
