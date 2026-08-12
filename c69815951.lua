--竜儀巧－メテオニス＝DRA
-- 效果：
-- 「流星辉巧群」降临
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：对方不能把场上的这张卡作为怪兽的效果的对象。
-- ②：这张卡的仪式召唤使用的怪兽的等级合计是2星以下的场合，这张卡可以向特殊召唤的对方怪兽全部各作1次攻击。
-- ③：对方回合，攻击力合计直到变成2000或4000为止从自己墓地把怪兽除外，以那个合计每2000为1张的对方场上的表侧表示卡为对象才能发动。那些卡送去墓地。
function c69815951.initial_effect(c)
	-- 记录这张卡记有「流星辉巧群」的卡名
	aux.AddCodeList(c,22398665)
	c:EnableReviveLimit()
	-- ②：这张卡的仪式召唤使用的怪兽的等级合计是2星以下的场合，这张卡可以向特殊召唤的对方怪兽全部各作1次攻击。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c69815951.valcheck)
	c:RegisterEffect(e0)
	-- ①：对方不能把场上的这张卡作为怪兽的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c69815951.efilter)
	c:RegisterEffect(e1)
	-- ②：这张卡的仪式召唤使用的怪兽的等级合计是2星以下的场合，这张卡可以向特殊召唤的对方怪兽全部各作1次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetCondition(c69815951.atkcon)
	e2:SetValue(c69815951.atkfilter)
	c:RegisterEffect(e2)
	-- ②：这张卡的仪式召唤使用的怪兽的等级合计是2星以下的场合，这张卡可以向特殊召唤的对方怪兽全部各作1次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c69815951.matcon)
	e3:SetOperation(c69815951.matop)
	c:RegisterEffect(e3)
	e0:SetLabelObject(e3)
	-- ③：对方回合，攻击力合计直到变成2000或4000为止从自己墓地把怪兽除外，以那个合计每2000为1张的对方场上的表侧表示卡为对象才能发动。那些卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(69815951,0))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCountLimit(1,69815951)
	e4:SetCondition(c69815951.tgcon)
	e4:SetCost(c69815951.tgcost)
	e4:SetTarget(c69815951.tgtg)
	e4:SetOperation(c69815951.tgop)
	c:RegisterEffect(e4)
end
-- 过滤成为对方怪兽效果对象的情况
function c69815951.efilter(e,re,rp)
	-- 如果是对方玩家发动的怪兽效果，则不能作为对象
	return aux.tgoval(e,re,rp) and re:IsActiveType(TYPE_MONSTER)
end
-- 检查这张卡是否有仪式召唤时等级合计在2星以下的标记
function c69815951.atkcon(e)
	return e:GetHandler():GetFlagEffect(69815951)>0
end
-- 过滤特殊召唤的怪兽
function c69815951.atkfilter(e,c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 判断是否为仪式召唤成功且仪式召唤使用的怪兽等级合计在2星以下
function c69815951.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and e:GetLabel()==1
end
-- 注册仪式召唤使用的怪兽的等级合计是2星以下的标记及客户端提示
function c69815951.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(69815951,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(69815951,1))  --"仪式召唤使用的怪兽的等级合计是2星以下"
end
-- 过滤有仪式等级的怪兽
function c69815951.lvfilter(c,rc)
	return c:GetRitualLevel(rc)>0
end
-- 检查仪式召唤使用的素材怪兽等级合计是否在2星以下并设置标签值
function c69815951.valcheck(e,c)
	local mg=c:GetMaterial()
	local fg=mg:Filter(c69815951.lvfilter,nil,c)
	if #fg>0 and fg:GetSum(Card.GetRitualLevel,c)<=2 then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断当前是否为对方回合
function c69815951.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤自己墓地中攻击力在1以上且可以作为Cost除外的怪兽
function c69815951.costfilter(c)
	return c:IsAttackAbove(1) and c:IsAbleToRemoveAsCost()
end
-- 过滤对方场上表侧表示且可以送去墓地的卡
function c69815951.tgfilter(c)
	return c:IsFaceup() and c:IsAbleToGrave()
end
-- 检查选取的除外怪兽攻击力合计是否正好为2000或4000
function c69815951.fselect(g,chk1,chk2)
	local sum=g:GetSum(Card.GetAttack)
	if chk2 then
		return sum==2000 or sum==4000
	elseif chk1 then
		return sum==2000
	end
	return false
end
-- 限制选择除外的怪兽攻击力合计不超过最大允许值
function c69815951.gcheck(maxatk)
	return	function(g)
				return g:GetSum(Card.GetAttack)<=maxatk
			end
end
-- 发动代价：从自己墓地除外攻击力合计为2000或4000的怪兽，并根据除外攻击力合计设置标签值
function c69815951.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100,0)
	-- 检查对方场上是否存在至少1张可以送去墓地的表侧表示卡
	local chk1=Duel.IsExistingTarget(c69815951.tgfilter,tp,0,LOCATION_ONFIELD,1,nil)
	-- 检查对方场上是否存在至少2张可以送去墓地的表侧表示卡
	local chk2=Duel.IsExistingTarget(c69815951.tgfilter,tp,0,LOCATION_ONFIELD,2,nil)
	local maxatk=2000
	if chk2 then maxatk=4000 end
	-- 获取自己墓地所有满足除外代价条件的怪兽
	local g=Duel.GetMatchingGroup(c69815951.costfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then
		if not chk1 then return false end
		-- 设置组选择的额外检查函数，限制所选怪兽的攻击力合计不超过最大值
		aux.GCheckAdditional=c69815951.gcheck(maxatk)
		local res=g:CheckSubGroup(c69815951.fselect,1,#g,chk1,chk2)
		-- 重置组选择的额外检查函数
		aux.GCheckAdditional=nil
		return res
	end
	-- 设置组选择的额外检查函数以进行实际除外卡片的选择
	aux.GCheckAdditional=c69815951.gcheck(maxatk)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c69815951.fselect,false,1,#g,chk1,chk2)
	-- 重置组选择的额外检查函数
	aux.GCheckAdditional=nil
	if sg:GetSum(Card.GetAttack)==4000 then
		e:SetLabel(100,2)
	else
		e:SetLabel(100,1)
	end
	-- 将选择的怪兽作为代价表侧表示除外
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 选取对方场上表侧表示的卡为效果对象
function c69815951.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c69815951.tgfilter(chkc) end
	local check,ct=e:GetLabel()
	if chk==0 then
		e:SetLabel(0,0)
		if check~=100 then return false end
		-- 检查对方场上是否存在可以送去墓地的卡作为对象
		return Duel.IsExistingTarget(c69815951.tgfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	e:SetLabel(0,0)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择指定数量的对方场上表侧表示卡作为效果对象
	local g=Duel.SelectTarget(tp,c69815951.tgfilter,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置在效果处理时将这些卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
-- 效果处理：将被选择为对象的对方场上的卡送去墓地
function c69815951.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与此效果相关的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		-- 将被选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
