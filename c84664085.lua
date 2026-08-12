--サテライト・ウォリアー
-- 效果：
-- 调整＋调整以外的同调怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合，以最多有自己墓地的同调怪兽数量的对方场上的卡为对象才能发动。那些卡破坏，这张卡的攻击力上升破坏数量×1000。
-- ②：同调召唤的这张卡被破坏的场合才能发动。8星以下的「战士」、「同调士」、「星尘」同调怪兽合计最多3只从自己墓地特殊召唤（同名卡最多1张）。
function c84664085.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置同调召唤手续：调整+调整以外的同调怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),1)
	-- ①：这张卡同调召唤的场合，以最多有自己墓地的同调怪兽数量的对方场上的卡为对象才能发动。那些卡破坏，这张卡的攻击力上升破坏数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84664085,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,84664085)
	e1:SetCondition(c84664085.descon)
	e1:SetTarget(c84664085.destg)
	e1:SetOperation(c84664085.desop)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被破坏的场合才能发动。8星以下的「战士」、「同调士」、「星尘」同调怪兽合计最多3只从自己墓地特殊召唤（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84664085,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,84664086)
	e2:SetCondition(c84664085.spcon)
	e2:SetTarget(c84664085.sptg)
	e2:SetOperation(c84664085.spop)
	c:RegisterEffect(e2)
end
c84664085.material_type=TYPE_SYNCHRO
-- 检查此卡是否为同调召唤成功
function c84664085.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①的发动准备：计算自己墓地同调怪兽数量，并选择对方场上对应数量的卡作为对象
function c84664085.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己墓地的同调怪兽数量
	local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SYNCHRO)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查发动条件：自己墓地有同调怪兽，且对方场上有至少1张可以作为对象的卡
	if chk==0 then return ct>0 and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择最多等同于自己墓地同调怪兽数量的对方场上的卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置当前连锁的操作信息，表明该效果包含破坏操作，操作对象为选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的处理：破坏选中的卡，并根据实际破坏的数量提升此卡的攻击力
function c84664085.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中仍与效果相关的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 破坏这些对象卡，并获取实际被破坏的卡片数量
	local ct=Duel.Destroy(tg,REASON_EFFECT)
	if ct~=0 then
		-- 这张卡的攻击力上升破坏数量×1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 过滤满足条件的怪兽：8星以下的「战士」、「同调士」或「星尘」同调怪兽，且可以特殊召唤
function c84664085.spfilter(c,e,tp)
	return c:IsLevelBelow(8) and c:IsSetCard(0x66,0x1017,0xa3) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查发动条件：此卡必须是在怪兽区域被破坏，且之前是同调召唤的状态
function c84664085.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果②的发动准备：检查自己场上是否有空位，以及墓地是否存在至少1只符合条件的怪兽
function c84664085.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足特殊召唤条件的特定同调怪兽
		and Duel.IsExistingMatchingCard(c84664085.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息，表明该效果包含从墓地特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的处理：从墓地选择最多3只卡名不同的特定同调怪兽特殊召唤
function c84664085.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地中所有满足条件且不受「王家长眠之谷」影响的同调怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c84664085.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 获取自己场上可用的怪兽区域空格数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 or g:GetCount()<=0 then return end
	local ct=math.min(ft,3)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 玩家从符合条件的怪兽中选择最多3只（且不超过可用空格数）卡名互不相同的怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
	-- 将选中的怪兽以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
