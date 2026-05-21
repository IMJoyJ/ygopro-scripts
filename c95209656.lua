--竜儀巧－メテオニス＝QUA
-- 效果：
-- 「流星辉巧群」降临。这个卡名的②③的效果1回合各能使用1次。
-- ①：场上的这张卡不会成为对方的魔法·陷阱卡的效果的对象。
-- ②：这张卡的仪式召唤使用的怪兽的等级合计是2星以下的场合才能发动。对方场上的魔法·陷阱卡全部破坏。
-- ③：仪式召唤的这张卡被破坏的场合才能发动。从自己墓地选攻击力合计直到变成4000为止的「龙仪巧-天龙流星QUA」以外的「龙辉巧」怪兽任意数量特殊召唤。
function c95209656.initial_effect(c)
	c:EnableReviveLimit()
	-- ②：这张卡的仪式召唤使用的怪兽的等级合计是2星以下的场合才能发动。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c95209656.valcheck)
	c:RegisterEffect(e0)
	-- ①：场上的这张卡不会成为对方的魔法·陷阱卡的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c95209656.efilter)
	c:RegisterEffect(e1)
	-- ②：这张卡的仪式召唤使用的怪兽的等级合计是2星以下的场合才能发动。对方场上的魔法·陷阱卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95209656,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,95209656)
	e2:SetCondition(c95209656.descon)
	e2:SetTarget(c95209656.destg)
	e2:SetOperation(c95209656.desop)
	c:RegisterEffect(e2)
	-- ②：这张卡的仪式召唤使用的怪兽的等级合计是2星以下的场合才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c95209656.matcon)
	e3:SetOperation(c95209656.matop)
	c:RegisterEffect(e3)
	e0:SetLabelObject(e3)
	-- ③：仪式召唤的这张卡被破坏的场合才能发动。从自己墓地选攻击力合计直到变成4000为止的「龙仪巧-天龙流星QUA」以外的「龙辉巧」怪兽任意数量特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(95209656,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,95209657)
	e4:SetCondition(c95209656.spcon)
	e4:SetTarget(c95209656.sptg)
	e4:SetOperation(c95209656.spop)
	c:RegisterEffect(e4)
end
-- 抗性过滤函数：判断是否为对方发动的魔法·陷阱卡的效果
function c95209656.efilter(e,re,rp)
	-- 返回是否为对方玩家发动的魔法或陷阱卡的效果
	return aux.tgoval(e,re,rp) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 仪式召唤成功且使用的素材等级合计在2星以下时的条件判断函数
function c95209656.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and e:GetLabel()==1
end
-- 仪式召唤成功时，给自身注册表示满足等级合计2星以下条件的Flag
function c95209656.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(95209656,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(95209656,2))  --"仪式召唤使用的怪兽的等级合计是2星以下"
end
-- 过滤函数：判断怪兽是否具有可用于仪式召唤该卡的仪式等级
function c95209656.lvfilter(c,rc)
	return c:GetRitualLevel(rc)>0
end
-- 素材检查函数：计算仪式召唤使用的素材怪兽的仪式等级合计是否在2星以下，并设置对应的Label
function c95209656.valcheck(e,c)
	local mg=c:GetMaterial()
	local fg=mg:Filter(c95209656.lvfilter,nil,c)
	if #fg>0 and fg:GetSum(Card.GetRitualLevel,c)<=2 then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 破坏效果发动条件：检查自身是否具有满足等级合计2星以下条件的Flag
function c95209656.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(95209656)>0
end
-- 破坏效果目标过滤与检测函数：检测并设置对方场上魔法·陷阱卡为破坏的操作信息
function c95209656.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有的魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	if chk==0 then return #g>0 end
	-- 设置连锁处理的操作信息为破坏对方场上的这些魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 破坏效果执行函数：将对方场上的魔法·陷阱卡全部破坏
function c95209656.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	if #g>0 then
		-- 因效果破坏选定的卡片组
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 特殊召唤效果发动条件：仪式召唤的这张卡从怪兽区域被破坏
function c95209656.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 特殊召唤过滤函数：过滤自己墓地中攻击力在1以上、卡名非本卡且可以特殊召唤的「龙辉巧」怪兽
function c95209656.spfilter(c,e,tp)
	return c:IsSetCard(0x154) and c:IsAttackAbove(1) and not c:IsCode(95209656)
		-- 且该卡可以被特殊召唤（根据是否为主卡组特殊召唤怪兽动态决定是否忽略苏生限制）
		and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.DrytronSpSummonType(c))
end
-- 子卡组选择条件：所选怪兽的攻击力合计必须刚好等于4000
function c95209656.fselect(g)
	return g:GetSum(Card.GetAttack)==4000
end
-- 动态检测函数：限制所选怪兽的攻击力合计不能超过4000
function c95209656.gcheck(g)
	return g:GetSum(Card.GetAttack)<=4000
end
-- 特殊召唤效果目标过滤与检测函数：计算可用怪兽区域并验证是否存在攻击力合计为4000的合法怪兽组合
function c95209656.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地中满足特殊召唤条件的「龙辉巧」怪兽
	local g=Duel.GetMatchingGroup(c95209656.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if chk==0 then
		if ft<=0 then return false end
		local ct=math.min(ft,#g)
		-- 设置卡片组选择的动态检测函数，限制攻击力合计不超过4000
		aux.GCheckAdditional=c95209656.gcheck
		local res=g:CheckSubGroup(c95209656.fselect,1,ct)
		-- 重置卡片组选择的动态检测函数
		aux.GCheckAdditional=nil
		return res
	end
	-- 设置连锁处理的操作信息为从墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 特殊召唤效果执行函数：从墓地选择攻击力合计为4000的「龙辉巧」怪兽特殊召唤
function c95209656.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地中满足特殊召唤条件且不受「王家长眠之谷」影响的「龙辉巧」怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c95209656.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ft<=0 then return end
	local ct=math.min(ft,#g)
	-- 设置卡片组选择的动态检测函数，限制攻击力合计不超过4000
	aux.GCheckAdditional=c95209656.gcheck
	-- 向玩家发送选择特殊召唤怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c95209656.fselect,false,1,ct)
	-- 重置卡片组选择的动态检测函数
	aux.GCheckAdditional=nil
	if sg then
		-- 遍历选定的特殊召唤怪兽卡片组
		for tc in aux.Next(sg) do
			-- 尝试将怪兽以表侧表示特殊召唤（若是主卡组特殊召唤怪兽则忽略苏生限制），若成功且为主卡组特殊召唤怪兽则执行后续处理
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,aux.DrytronSpSummonType(tc),POS_FACEUP) and aux.DrytronSpSummonType(tc) then
				tc:CompleteProcedure()
			end
		end
		-- 完成特殊召唤的流程处理
		Duel.SpecialSummonComplete()
	end
end
