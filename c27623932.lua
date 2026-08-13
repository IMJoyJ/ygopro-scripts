--サンダー・ディスチャージ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「勇者衍生物」存在的场合，以把有「勇者衍生物」的衍生物名记述的装备卡装备的自己场上1只怪兽为对象才能发动。持有那只怪兽的攻击力以下的攻击力的对方场上的怪兽全部破坏。那之后，可以从自己的手卡·墓地选有「勇者衍生物」的衍生物名记述的1张装备魔法卡给自己场上1只可以装备的怪兽装备。
local s,id,o=GetID()
-- 初始化效果函数：将本卡卡名记述的「勇者衍生物」加入代码列表，创建并注册魔法卡发动效果；设置效果分类为破坏、类型为魔法发动、自由时点、取对象、同名卡1回合只能发动1次的誓约次数限制，并设定提示时点、发动条件、发动时选择目标和效果处理函数。
function c27623932.initial_effect(c)
	-- 将卡号3285552（勇者衍生物）记录为本卡效果文本中记述的卡名，供后续用aux.IsCodeListed判断“有「勇者衍生物」的衍生物名记述”。
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
-- 过滤函数cfilter：判定卡为表侧表示的「勇者衍生物」（卡号3285552）。
function c27623932.cfilter(c)
	return c:IsCode(3285552) and c:IsFaceup()
end
-- 发动条件函数：自己场上有表侧表示的「勇者衍生物」存在时才能发动本卡。
function c27623932.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（怪兽区+魔陷区）是否存在至少1张表侧表示的「勇者衍生物」。
	return Duel.IsExistingMatchingCard(c27623932.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 对象筛选函数tgfilter：选择自己场上1只表侧表示怪兽，该怪兽必须装备着至少1张表侧表示且卡名记述了「勇者衍生物」的装备卡，并且对方场上有攻击力不大于该怪兽当前攻击力的表侧表示怪兽。
function c27623932.tgfilter(c,tp)
	return c:IsFaceup() and c:GetEquipCount()>0 and c:GetEquipGroup():IsExists(c27623932.cfilter2,1,nil)
		-- 附加条件：对方场上存在至少1只攻击力不高于该怪兽当前攻击力的表侧表示怪兽，使破坏效果有处理对象。
		and Duel.IsExistingMatchingCard(c27623932.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
-- 过滤函数cfilter2：判定一张卡是表侧表示且其效果文本中记述了「勇者衍生物」（卡号3285552）。
function c27623932.cfilter2(c)
	-- 返回条件：卡为表侧表示，且卡名记述了「勇者衍生物」。
	return c:IsFaceup() and aux.IsCodeListed(c,3285552)
end
-- 破坏筛选函数desfilter：对方场上的表侧表示怪兽，攻击力小于等于传入的攻击力数值atk。
function c27623932.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- 发动时目标函数target：处理发动时的合法性检查、选择对象怪兽，并预计算要破坏的对方怪兽组，设置破坏的操作信息。
function c27623932.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c27623932.tgfilter(chkc) end
	-- 检查发动时是否存在合法目标：自己场上有满足tgfilter的怪兽，且对方场上有可被破坏的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c27623932.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 给出选择提示，要求玩家选择表侧表示的卡（作为对象怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家从自己场上选择1只满足条件的表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c27623932.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 以所选对象怪兽的攻击力为基准，获取对方场上所有攻击力在该数值以下的表侧表示怪兽。
	local dg=Duel.GetMatchingGroup(c27623932.desfilter,tp,0,LOCATION_MZONE,nil,g:GetFirst():GetAttack())
	-- 设置当前连锁的操作信息：要破坏的卡组为dg，数量为dg:GetCount()，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- CanEquipFilter：判断表侧表示的怪兽c能否被指定的装备魔法卡eqc装备。
function c27623932.CanEquipFilter(c,eqc)
	return c:IsFaceup() and eqc:CheckEquipTarget(c)
end
-- eqfilter：筛选手牌/墓地中的装备魔法卡，要求卡名记述「勇者衍生物」、是装备魔法、满足同名卡唯一限制、不是禁止卡，并且自己场上有可以装备它的表侧表示怪兽。
function c27623932.eqfilter(c,tp)
	-- 该卡必须卡名记述「勇者衍生物」、是装备魔法、满足场上同名卡唯一限制且不属于禁止卡。
	return aux.IsCodeListed(c,3285552) and c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		-- 该装备魔法卡必须能装备给自己场上至少1只表侧表示的怪兽。
		and Duel.IsExistingMatchingCard(c27623932.CanEquipFilter,tp,LOCATION_MZONE,0,1,nil,c)
end
-- 效果处理函数operation：取得对象怪兽，按当前攻击力选择并破坏对方场上符合条件的怪兽；若破坏成功且满足后续条件，则询问玩家后从手卡/墓地选择装备魔法卡装备给自己场上的怪兽。
function c27623932.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得处理时得到的对象怪兽（自己场上那只装备了相关装备卡的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 根据对象怪兽当前攻击力，获取对方场上攻击力不高于该数值的表侧表示怪兽作为破坏对象。
		local dg=Duel.GetMatchingGroup(c27623932.desfilter,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
		-- 执行破坏；若实际破坏数量不为0，且自己魔陷区有空位，才继续后续装备处理。
		if Duel.Destroy(dg,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			-- 检查手牌/墓地是否存在符合条件的装备魔法卡，并用aux.NecroValleyFilter排除因王家长眠之谷而不能从墓地使用的卡。
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp)
			-- 询问玩家是否要进行后续的装备处理，对应“那之后，可以从自己的手卡·墓地选……”的效果。
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否选装备魔法卡装备？"
			-- 中断当前效果处理，使后续装备处理与破坏处理不在同一时点进行，避免错过时点。
			Duel.BreakEffect()
			-- 给出选择装备魔法卡的提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 从手牌/墓地选择1张符合条件的装备魔法卡（经过王家长眠之谷过滤）。
			local eqg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp)
			local eqc=eqg:GetFirst()
			-- 给出选择要装备的怪兽的提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			-- 选择自己场上1只可以装备该装备魔法卡的表侧表示怪兽作为装备对象。
			local mg=Duel.SelectMatchingCard(tp,s.CanEquipFilter,tp,LOCATION_MZONE,0,1,1,nil,eqc)
			-- 执行装备操作，将选好的装备魔法卡装备给选择好的怪兽。
			Duel.Equip(tp,eqc,mg:GetFirst())
		end
	end
end
