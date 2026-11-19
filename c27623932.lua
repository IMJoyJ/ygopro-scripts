--サンダー・ディスチャージ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「勇者衍生物」存在的场合，以把有「勇者衍生物」的衍生物名记述的装备卡装备的自己场上1只怪兽为对象才能发动。持有那只怪兽的攻击力以下的攻击力的对方场上的怪兽全部破坏。那之后，可以从自己的手卡·墓地选有「勇者衍生物」的衍生物名记述的1张装备魔法卡给自己场上1只可以装备的怪兽装备。
local s,id,o=GetID()
-- 初始化「雷霆放电」的效果：记录「勇者衍生物」卡名记述，并注册卡片发动效果（1回合1张，自己场上有「勇者衍生物」时取装备有记述「勇者衍生物」装备卡的己方1只怪兽为对象，破坏对方场上的怪兽并可追加装备）。
function c27623932.initial_effect(c)
	-- 记录这张卡的效果文本上记载了「勇者衍生物」(3285552)的卡名。
	aux.AddCodeList(c,3285552)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「勇者衍生物」存在的场合，以把有「勇者衍生物」的衍生物名记述的装备卡装备的自己场上1只怪兽为对象才能发动。持有那只怪兽的攻击力以下的攻击力的对方场上的怪兽全部破坏。那之后，可以从自己的手卡·墓地选有「勇者衍生物」的衍生物名记述的1张装备魔法卡给自己场上1只可以装备的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,27623932+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c27623932.condition)
	e1:SetTarget(c27623932.target)
	e1:SetOperation(c27623932.operation)
	c:RegisterEffect(e1)
end
-- 定义过滤函数，检查卡片是否为表侧表示的「勇者衍生物」(3285552)。
function c27623932.cfilter(c)
	return c:IsCode(3285552) and c:IsFaceup()
end
-- 发动条件检查函数：确认自己场上是否存在表侧表示的「勇者衍生物」。
function c27623932.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「勇者衍生物」。
	return Duel.IsExistingMatchingCard(c27623932.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 定义对象过滤函数，检查怪兽是否表侧表示、装备着有「勇者衍生物」记述的表侧装备卡，且对方场上存在攻击力在该怪兽攻击力以下的怪兽。
function c27623932.tgfilter(c,tp)
	return c:IsFaceup() and c:GetEquipCount()>0 and c:GetEquipGroup():IsExists(c27623932.cfilter2,1,nil)
		-- 检查对方怪兽区域是否存在至少1只攻击力在目标怪兽攻击力以下的表侧表示怪兽。
		and Duel.IsExistingMatchingCard(c27623932.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
-- 定义过滤函数，检查装备卡是否为表侧表示且记述了「勇者衍生物」的卡名。
function c27623932.cfilter2(c)
	-- 判断卡片是否为表侧表示且效果文本中记述了「勇者衍生物」(3285552)。
	return c:IsFaceup() and aux.IsCodeListed(c,3285552)
end
-- 定义破坏目标过滤函数，检查怪兽是否为表侧表示且当前攻击力在指定攻击力atk以下。
function c27623932.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- 发动对象检查与宣言处理函数：验证条件并选择自己场上1只符合条件的目标怪兽，同时登记要破坏的对方怪兽操作信息。
function c27623932.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c27623932.tgfilter(chkc,tp) end
	-- 在检查能否发动时，确认自己怪兽区存在至少1只符合条件且可成为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c27623932.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向玩家发送选择表侧表示卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己怪兽区选择1只满足条件的目标怪兽并设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c27623932.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 获取对方怪兽区所有攻击力在对象怪兽攻击力以下的表侧表示怪兽卡片组。
	local dg=Duel.GetMatchingGroup(c27623932.desfilter,tp,0,LOCATION_MZONE,nil,g:GetFirst():GetAttack())
	-- 向引擎登记本次连锁确定执行的破坏操作信息及涉及的对方怪兽卡片组。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 定义可装备怪兽过滤函数，检查自己场上的怪兽是否为表侧表示且能被指定的装备卡eqc合法装备。
function c27623932.CanEquipFilter(c,eqc)
	return c:IsFaceup() and eqc:CheckEquipTarget(c)
end
-- 定义装备魔法过滤函数，检查卡片是否记述「勇者衍生物」、为装备魔法、不违反场上同名唯一限制且未被禁止使用，同时场上存在可装备它的自己怪兽。
function c27623932.eqfilter(c,tp)
	-- 判断卡片是否记述「勇者衍生物」、属于装备魔法、符合己方场上唯一性限制且未被禁止使用。
	return aux.IsCodeListed(c,3285552) and c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		-- 检查自己怪兽区是否存在至少1只可被该装备魔法卡合法装备的怪兽。
		and Duel.IsExistingMatchingCard(c27623932.CanEquipFilter,tp,LOCATION_MZONE,0,1,nil,c)
end
-- 效果处理函数：确认对象怪兽仍在场且表侧表示后，破坏对方场上攻击力在其以下的怪兽；若成功破坏，可从手卡·墓地选1张记述「勇者衍生物」的装备魔法卡装备给己方怪兽。
function c27623932.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的当前连锁的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 再次获取对方怪兽区所有攻击力在对象怪兽当前攻击力以下的表侧表示怪兽卡片组。
		local dg=Duel.GetMatchingGroup(c27623932.desfilter,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
		-- 破坏筛选出的对方怪兽，若至少破坏了1只且自己魔法与陷阱区仍有空位则继续判定追加装备条件。
		if Duel.Destroy(dg,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			-- 检查自己的手卡或墓地是否存在至少1张满足装备条件且不受「王家长眠之谷」影响的装备魔法卡。
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp)
			-- 询问发动玩家是否要从手卡·墓地选择1张装备魔法卡进行装备。
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否选装备魔法卡装备？"
			-- 插入效果中断，使后续的装备处理与前面的破坏处理视为不同时处理。
			Duel.BreakEffect()
			-- 向玩家发送选择要装备的卡的提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 让玩家从手卡或墓地选择1张满足条件且不受「王家长眠之谷」影响的装备魔法卡。
			local eqg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp)
			local eqc=eqg:GetFirst()
			-- 向玩家发送选择表侧表示怪兽作为装备对象的提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			-- 让玩家从自己怪兽区选择1只可以装备所选装备魔法卡的表侧表示怪兽。
			local mg=Duel.SelectMatchingCard(tp,s.CanEquipFilter,tp,LOCATION_MZONE,0,1,1,nil,eqc)
			-- 将选中的装备魔法卡以表侧表示装备给选中的自己场上怪兽。
			Duel.Equip(tp,eqc,mg:GetFirst())
		end
	end
end
