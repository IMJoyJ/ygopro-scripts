--スクラップ・マインドリーダー
-- 效果：
-- 这张卡在墓地存在的场合，自己的主要阶段2才能发动1次。选择「废铁读心者」以外的自己场上表侧表示存在的1只名字带有「废铁」的怪兽破坏，这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。把这张卡作为同调素材的场合，其他的同调素材怪兽必须全部是名字带有「废铁」的怪兽。
function c67038874.initial_effect(c)
	-- 这张卡在墓地存在的场合，自己的主要阶段2才能发动1次。选择「废铁读心者」以外的自己场上表侧表示存在的1只名字带有「废铁」的怪兽破坏，这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67038874,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c67038874.condition)
	e1:SetTarget(c67038874.target)
	e1:SetOperation(c67038874.operation)
	c:RegisterEffect(e1)
	-- 把这张卡作为同调素材的场合，其他的同调素材怪兽必须全部是名字带有「废铁」的怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TUNER_MATERIAL_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetTarget(c67038874.synlimit)
	c:RegisterEffect(e2)
end
-- 定义效果发动条件函数，限制只能在主要阶段2发动。
function c67038874.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤出自己场上表侧表示存在的「废铁读心者」以外的名字带有「废铁」的怪兽。
function c67038874.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x24) and not c:IsCode(67038874)
end
-- 定义效果发动时的目标选择与合法性检测函数。
function c67038874.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前进行检测，检查自己场上是否存在符合条件的「废铁」怪兽作为对象，且自身是否能从墓地特殊召唤。
	if chk==0 then return Duel.IsExistingTarget(c67038874.filter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只符合条件的「废铁」怪兽作为效果对象并进行取对象操作。
	local g=Duel.SelectTarget(tp,c67038874.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置破坏操作的连锁信息，包含选定的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置特殊召唤操作的连锁信息，包含自身卡片。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义效果处理函数，执行破坏和特殊召唤，并注册离场除外的效果。
function c67038874.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动阶段选择的作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查自身和目标怪兽是否仍与效果相关，且目标怪兽仍表侧表示存在，将其破坏。
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 若破坏成功，则将自身从墓地表侧表示特殊召唤。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。把这张卡作为同调素材的场合，其他的同调素材怪兽必须全部是名字带有「废铁」的怪兽。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 限制同调素材必须全部是名字带有「废铁」的怪兽。
function c67038874.synlimit(e,c)
	return c:IsSetCard(0x24)
end
