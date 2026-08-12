--エクシーズ・ダブル・バック
-- 效果：
-- 自己场上的超量怪兽被破坏的回合，自己场上没有怪兽存在的场合才能发动。从自己墓地选择1只那个回合被破坏的超量怪兽和1只那只怪兽的攻击力以下的怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段时破坏。
function c57836546.initial_effect(c)
	-- 自己场上的超量怪兽被破坏的回合，自己场上没有怪兽存在的场合才能发动。从自己墓地选择1只那个回合被破坏的超量怪兽和1只那只怪兽的攻击力以下的怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c57836546.condition)
	e1:SetTarget(c57836546.target)
	e1:SetOperation(c57836546.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：检查自己场上是否存在怪兽
function c57836546.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤条件1：筛选自己墓地中在当前回合被破坏并送去墓地的原本正面表示的超量怪兽，且墓地中存在另一只攻击力在其以下、可特殊召唤的怪兽
function c57836546.filter1(c,e,tp,turn)
	return c:IsType(TYPE_XYZ) and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:GetTurnID()==turn and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断自己墓地中是否存在另一只攻击力在选定的超量怪兽攻击力以下、且可以特殊召唤的怪兽
		and Duel.IsExistingTarget(c57836546.filter2,tp,LOCATION_GRAVE,0,1,c,e,tp,c:GetAttack())
end
-- 过滤条件2：筛选自己墓地中攻击力在指定数值以下、且可以特殊召唤的怪兽
function c57836546.filter2(c,e,tp,atk)
	return c:IsAttackBelow(atk) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的效果处理（取对象）：检查是否满足特殊召唤2只怪兽的条件（包括不受青眼精灵龙限制、有2个以上空怪兽区域、以及存在符合条件的超量怪兽）
function c57836546.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的怪兽区域空位数是否大于1
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查自己墓地是否存在符合条件的、在当前回合被破坏的超量怪兽
		and Duel.IsExistingTarget(c57836546.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,Duel.GetTurnCount()) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只在当前回合被破坏的超量怪兽作为效果的对象
	local g1=Duel.SelectTarget(tp,c57836546.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,Duel.GetTurnCount())
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只攻击力在上述超量怪兽以下、且不是该超量怪兽本身的怪兽作为效果的对象
	local g2=Duel.SelectTarget(tp,c57836546.filter2,tp,LOCATION_GRAVE,0,1,1,g1:GetFirst(),e,tp,g1:GetFirst():GetAttack())
	g1:Merge(g2)
	-- 设置效果处理信息，表示此效果将特殊召唤选定的2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 效果处理：将选定的2只怪兽特殊召唤，并注册在结束阶段将其破坏的效果
function c57836546.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取当前连锁中仍与此效果有关联的选定对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 如果关联的怪兽数量不等于2，或者自己场上的怪兽区域空位数不足2个，则不处理效果
	if g:GetCount()~=2 or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local fid=e:GetHandler():GetFieldID()
	local tc=g:GetFirst()
	while tc do
		-- 尝试将目标怪兽以表侧表示特殊召唤到自己场上
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			tc:RegisterFlagEffect(57836546,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		end
		tc=g:GetNext()
	end
	-- 完成怪兽的特殊召唤流程
	Duel.SpecialSummonComplete()
	g:KeepAlive()
	-- 这个效果特殊召唤的怪兽在结束阶段时破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetCondition(c57836546.descon)
	e1:SetOperation(c57836546.desop)
	e1:SetLabel(fid)
	e1:SetLabelObject(g)
	-- 将用于在结束阶段破坏特殊召唤怪兽的延迟效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：筛选带有当前特殊召唤标记的怪兽
function c57836546.desfilter(c,fid)
	return c:GetFlagEffectLabel(57836546)==fid
end
-- 延迟破坏效果的发动条件：检查被特殊召唤的怪兽是否还存在于场上，若不存在则重置该效果
function c57836546.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c57836546.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 延迟破坏效果的处理：将所有带有对应标记的、由该效果特殊召唤的怪兽破坏
function c57836546.desop(e,tp,eg,ep,ev,re,r,rp)
	local sg=e:GetLabelObject()
	local dg=sg:Filter(c57836546.desfilter,nil,e:GetLabel())
	if dg:GetCount()>0 then
		-- 因效果将目标怪兽破坏
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
