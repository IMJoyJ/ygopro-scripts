--竜儀巧－メテオニス＝QUA
-- 效果：
-- 「流星辉巧群」降临。这个卡名的②③的效果1回合各能使用1次。
-- ①：场上的这张卡不会成为对方的魔法·陷阱卡的效果的对象。
-- ②：这张卡的仪式召唤使用的怪兽的等级合计是2星以下的场合才能发动。对方场上的魔法·陷阱卡全部破坏。
-- ③：仪式召唤的这张卡被破坏的场合才能发动。从自己墓地选攻击力合计直到变成4000为止的「龙仪巧-天龙流星QUA」以外的「龙辉巧」怪兽任意数量特殊召唤。
function c95209656.initial_effect(c)
	-- 在卡片关联代码列表中添加「流星辉巧群」的卡片密码
	aux.AddCodeList(c,22398665)
	c:EnableReviveLimit()
	-- 注册仪式召唤素材检测效果（用于辅助检测仪式召唤所用素材的合计等级）
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
	-- 注册在特殊召唤成功时触发的标记注册效果，用来记录仪式召唤所使用的怪兽等级合计是否是2星以下
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
-- 效果①中对方魔法·陷阱卡效果抗性的过滤条件函数
function c95209656.efilter(e,re,rp)
	-- 判定效果是否由对方发动的魔法或陷阱卡
	return aux.tgoval(e,re,rp) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 判定是否为仪式召唤成功且素材的等级合计是2星以下
function c95209656.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and e:GetLabel()==1
end
-- 在怪兽身上注册标记（Flag），该标记包含仪式召唤时素材等级合计在2星以下的提示语
function c95209656.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(95209656,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(95209656,2))  --"仪式召唤使用的怪兽的等级合计是2星以下"
end
-- 仪式召唤素材的过滤条件（具有仪式等级的卡）
function c95209656.lvfilter(c,rc)
	return c:GetRitualLevel(rc)>0
end
-- 检查仪式召唤时所使用素材的合计等级，如果小于等于2，则对标记效果注册标志位1
function c95209656.valcheck(e,c)
	local mg=c:GetMaterial()
	local fg=mg:Filter(c95209656.lvfilter,nil,c)
	if #fg>0 and fg:GetSum(Card.GetRitualLevel,c)<=2 then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 效果②的发动条件：检测自身是否带有仪式素材等级合计在2星以下的标志
function c95209656.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(95209656)>0
end
-- 效果②的发动准备与目标选择（Target）函数
function c95209656.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	if chk==0 then return #g>0 end
	-- 设置连锁信息：包含破坏对方场上所有魔法·陷阱卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 效果②的效果处理（Operation）函数
function c95209656.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	if #g>0 then
		-- 破坏对方场上所有的魔法·陷阱卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 效果③的发动条件判定函数：原本在场上且是仪式召唤状态的这张卡被破坏的场合
function c95209656.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 效果③特殊召唤对象的过滤条件：墓地中除了「龙仪巧-天龙流星QUA」以外，攻击力在1以上且可以特殊召唤的「龙辉巧」怪兽
function c95209656.spfilter(c,e,tp)
	return c:IsSetCard(0x154) and c:IsAttackAbove(1) and not c:IsCode(95209656)
		-- 检查怪兽是否能被特殊召唤（其中根据「龙辉巧」的特征判定是否无视苏生限制）
		and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.DrytronSpSummonType(c))
end
-- 筛选函数：检查所选择的怪兽的攻击力合计是否恰好为4000
function c95209656.fselect(g)
	return g:GetSum(Card.GetAttack)==4000
end
-- 递归筛选辅助函数：确保选择过程中的攻击力合计不超过4000
function c95209656.gcheck(g)
	return g:GetSum(Card.GetAttack)<=4000
end
-- 效果③的发动准备与目标选择（Target）函数
function c95209656.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地所有可特殊召唤的「龙辉巧」怪兽
	local g=Duel.GetMatchingGroup(c95209656.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if chk==0 then
		if ft<=0 then return false end
		local ct=math.min(ft,#g)
		-- 开启限制条件检测：让玩家在选择怪兽时攻击力合计不得超过4000
		aux.GCheckAdditional=c95209656.gcheck
		local res=g:CheckSubGroup(c95209656.fselect,1,ct)
		-- 关闭限制条件检测
		aux.GCheckAdditional=nil
		return res
	end
	-- 设置连锁信息：包含从墓地特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果③的效果处理（Operation）函数
function c95209656.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地中所有满足特殊召唤条件的「龙辉巧」怪兽（受王家长眠之谷限制）
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c95209656.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ft<=0 then return end
	local ct=math.min(ft,#g)
	-- 开启限制条件检测：让玩家在选择怪兽时攻击力合计不得超过4000
	aux.GCheckAdditional=c95209656.gcheck
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c95209656.fselect,false,1,ct)
	-- 关闭限制条件检测
	aux.GCheckAdditional=nil
	if sg then
		-- 遍历玩家选择的将要特殊召唤的怪兽
		for tc in aux.Next(sg) do
			-- 将怪兽以表侧表示特殊召唤到场上（若该怪兽是主卡组的特殊召唤怪兽，则无视其苏生限制并完成召唤手续）
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,aux.DrytronSpSummonType(tc),POS_FACEUP) and aux.DrytronSpSummonType(tc) then
				tc:CompleteProcedure()
			end
		end
		-- 完成本连锁中所有怪兽的特殊召唤手续
		Duel.SpecialSummonComplete()
	end
end
