--色鬼の蟲毒
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●这张卡变成通常怪兽（昆虫族·调整·暗·1星·攻/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。那之后，可以进行1只同调怪兽的同调召唤。
-- ●以自己墓地1只「艮神鬼」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册这张卡的发动效果e1：属于特殊召唤分类、魔陷发动类型、自由时点（在怪兽正面上场或结束阶段时点提示发动）、取对象，并设定同名卡1回合只能发动1张，指定目标函数和处理函数后注册给这张卡
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断卡片是否属于「艮神鬼」字段且可以被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1e4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标函数：分别判断两个选项是否可用——b1为自己怪兽区有空位且可以把这张卡当作调整陷阱怪兽特殊召唤，b2为自己怪兽区有空位且自己墓地存在可取为对象的「艮神鬼」怪兽；发动条件确认后让玩家从可用选项中选择1个发动；选选项1时取消取对象并设置将这张卡特殊召唤的操作信息，选选项2时设定取对象、选择自己墓地1只「艮神鬼」怪兽为对象并设置将其特殊召唤的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	local b1=e:IsCostChecked()
		-- 确认自己场上主要怪兽区域有可用空格（用于选项1把这张卡特殊召唤到怪兽区域）
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认可以把这张卡变成通常怪兽（昆虫族·调整·暗·1星·攻/守0）特殊召唤（陷阱怪兽判定）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1e4,TYPES_NORMAL_TRAP_MONSTER+TYPE_TUNER,0,0,1,RACE_INSECT,ATTRIBUTE_DARK)
	-- 确认自己场上主要怪兽区域有可用空格（用于选项2特殊召唤墓地怪兽）
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己墓地存在可以成为效果对象且可以特殊召唤的「艮神鬼」怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家从可用的效果选项中选择1个发动（选项1：当作怪兽特殊召唤；选项2：特殊召唤墓地怪兽）
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"当作怪兽特殊召唤"
			{b2,aux.Stringid(id,2),2})  --"特殊召唤墓地怪兽"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetProperty(0)
		end
		-- 设置操作信息：发动时将这张卡自身特殊召唤1张
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		end
		-- 提示玩家请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 以自己墓地1只可以特殊召唤的「艮神鬼」怪兽为对象，并将其设为本次连锁的对象卡
		local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 设置操作信息：发动时将所选的对象卡特殊召唤1张
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 效果处理：若选择选项1，这张卡与连锁关联且可以当作陷阱怪兽特殊召唤时，给这张卡添加通常怪兽·调整属性并将其特殊召唤；特殊召唤成功后若额外卡组存在可以同调召唤的怪兽，询问玩家是否同调召唤，确认则错开时点选择1只进行同调召唤；若选择选项2，将对象的那只墓地的「艮神鬼」怪兽特殊召唤（受王家长眠之谷判定）
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local c=e:GetHandler()
		-- 确认这张卡仍与连锁关联，且当前仍可以把这张卡变成通常怪兽（昆虫族·调整·暗·1星·攻/守0）特殊召唤
		if c:IsRelateToChain() and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1e4,TYPES_NORMAL_TRAP_MONSTER+TYPE_TUNER,0,0,1,RACE_INSECT,ATTRIBUTE_DARK) then
			c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TUNER)
			-- 把这张卡不当作陷阱卡使用、以表侧表示在怪兽区域特殊召唤，并确认特殊召唤成功
			if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
				-- 检索自己额外卡组中当前可以进行同调召唤的同调怪兽
				local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
				-- 若存在可以同调召唤的怪兽，询问玩家是否进行同调召唤
				if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否同调召唤？"
					-- 中断当前效果处理，使同调召唤与之前的特殊召唤不作为同时处理（错开时点）
					Duel.BreakEffect()
					-- 提示玩家请选择要特殊召唤（同调召唤）的卡
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					local sg=g:Select(tp,1,1,nil)
					-- 以这张卡为调整，对玩家选择的1只额外卡组怪兽进行同调召唤
					Duel.SynchroSummon(tp,sg:GetFirst(),nil)
				end
			end
		end
	elseif e:GetLabel()==2 then
		-- 取得本次连锁的对象卡（之前选择的墓地「艮神鬼」怪兽）
		local tc=Duel.GetFirstTarget()
		-- 确认对象卡仍与连锁关联，且不受王家长眠之谷的影响
		if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
			-- 将对象的那只怪兽在自己场上以表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
