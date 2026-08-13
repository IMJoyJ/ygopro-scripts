--絢嵐たる海霊ヴァルルーン
-- 效果：
-- 「绚岚」怪兽2只
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从自己的卡组·墓地把1张「旋风」加入手卡。
-- ②：以包含自己场上的「绚岚」怪兽的场上2只表侧表示怪兽为对象才能发动。那些怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
-- ③：速攻魔法卡发动的场合才能发动。从自己的卡组·墓地把1张「绚岚」永续陷阱卡在自己场上表侧表示放置。
local s,id,o=GetID()
-- 初始化效果函数：登记卡名参照、连接召唤手续，并依次注册①检索旋风、②放置为永续魔法、③放置绚岚永续陷阱三个效果。
function s.initial_effect(c)
	-- 登记此卡效果文中提到的「旋风」（卡号5318639），用于卡名参照等判定。
	aux.AddCodeList(c,5318639)
	-- 设定连接召唤素材条件：2只「绚岚」连接怪兽（使用辅助过滤函数要求同时满足连接怪兽与「绚岚」字段）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x1d1),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从自己的卡组·墓地把1张「旋风」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：以包含自己场上的「绚岚」怪兽的场上2只表侧表示怪兽为对象才能发动。那些怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"当作永续魔法卡放置"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.mvtg)
	e2:SetOperation(s.mvop)
	c:RegisterEffect(e2)
	-- ③：速攻魔法卡发动的场合才能发动。从自己的卡组·墓地把1张「绚岚」永续陷阱卡在自己场上表侧表示放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"放置永续陷阱卡"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+2*o)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：此卡是通过连接召唤方式特殊召唤成功的场合。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤条件：卡名是「旋风」（5318639）且能够加入手卡。
function s.filter(c)
	return c:IsCode(5318639) and c:IsAbleToHand()
end
-- 效果①发动时的目标判定：检查卡组·墓地是否存在「旋风」，若存在则预置‘从卡组·墓地加入手卡’的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动检查（chk==0）：己方卡组·墓地中是否存在至少1张满足s.filter的「旋风」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 将本次连锁的操作信息设定为检索1张卡加入手卡（来源为卡组·墓地），供其他效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①处理：从自己卡组·墓地将1张「旋风」加入手卡，并让对方确认；检索结果受王家长眠之谷影响时使用NecroValleyFilter过滤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出卡片选择提示“请选择要加入手牌的卡”，引导玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让己方从卡组·墓地选择1张满足s.filter且不受王家长眠之谷影响的「旋风」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②对象候选过滤：表侧表示怪兽，且控制权为其原本持有者或能够变更控制权，同时不是禁止状态且其持有者场上不会出现同名卡重复。
function s.mvfilter(c)
	return c:IsFaceup() and (c:IsControler(c:GetOwner()) or c:IsAbleToChangeControler())
		and not c:IsForbidden() and c:CheckUniqueOnField(c:GetOwner())
end
-- 效果②处理时的二次过滤：目标卡仍是怪兽、控制权条件满足、不免疫此效果、不是禁止状态且持有者场上不会出现同名卡重复。
function s.mvfilter2(c,e)
	return c:IsType(TYPE_MONSTER) and (c:IsControler(c:GetOwner()) or c:IsAbleToChangeControler())
		and not c:IsImmuneToEffect(e)
		and not c:IsForbidden() and c:CheckUniqueOnField(c:GetOwner())
end
-- 判断卡的原本持有者是否为指定玩家p。
function s.isowner(c,tp)
	return c:GetOwner()==tp
end
-- 判断怪兽是否为「绚岚」字段且当前控制者为己方tp。
function s.tgfilter(c,tp)
	return c:IsSetCard(0x1d1) and c:IsControler(tp)
end
-- 检查所选2只怪兽组合：按各自原本持有者分别计算需占用的魔陷区空格数，且其中至少有1只是己方场上的「绚岚」怪兽。
function s.gcheck(g,tp)
	-- 统计所选怪兽中原本持有者为玩家0的数量，并确认不超过玩家0的魔法陷阱区空格数。
	return g:FilterCount(s.isowner,nil,0)<=Duel.GetLocationCount(0,LOCATION_SZONE)
		-- 统计所选怪兽中原本持有者为玩家1的数量，并确认不超过玩家1的魔法陷阱区空格数。
		and g:FilterCount(s.isowner,nil,1)<=Duel.GetLocationCount(1,LOCATION_SZONE)
		and g:FilterCount(s.tgfilter,nil,tp)>0
end
-- 效果②发动时：从场上表侧表示怪兽中选出2只作为对象，要求包含己方场上的「绚岚」怪兽且原持有者魔陷区空位足够，随后将选中的卡设为对象。
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取场上全部符合初步过滤且能成为效果对象的表侧表示怪兽，形成候选组。
	local g=Duel.GetMatchingGroup(s.mvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil):Filter(Card.IsCanBeEffectTarget,nil,e)
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2,tp) end
	-- 弹出卡片选择提示“请选择要放置到场上的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
	-- 将选中的2只怪兽登记为当前连锁的对象卡。
	Duel.SetTargetCard(sg)
end
-- 效果②处理：将仍关联的目标怪兽按原本持有者分别移动到其魔陷区表侧表示；若某持有者空位不足则只移动可容纳数量，其余按规则送入墓地；移动后的怪兽被赋予永续魔法卡类型。
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e):Filter(s.mvfilter2,nil,e)
	local pg=Group.CreateGroup()
	-- 依次遍历双方玩家（当前回合玩家与其对方），分别处理属于各玩家持有的目标怪兽。
	for p in aux.TurnPlayers() do
		local sg=tg:Filter(s.isowner,nil,p)
		-- 获取玩家p的魔法陷阱区可用空格数。
		local ct=Duel.GetLocationCount(p,LOCATION_SZONE)
		if sg:GetCount()<=ct then
			pg:Merge(sg)
		elseif ct>0 then
			-- 当某持有者的魔陷区空位不足时，弹出“请选择要操作的卡”的提示，由己方选择可放置的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
			local tpg=sg:Select(tp,ct,ct,nil)
			pg:Merge(tpg)
		end
	end
	-- 遍历最终确定可以移动的怪兽组pg中的每张卡。
	for tc in aux.Next(pg) do
		-- 将目标卡以表侧表示移动到其原本持有者的魔法陷阱区，并立即适用其效果。
		Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true)
		-- 那些怪兽当作永续魔法卡使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
	local gg=tg-pg
	if gg:GetCount()>0 then
		-- 将无法放置到魔陷区的剩余对象怪兽按规则送入墓地。
		Duel.SendtoGrave(gg,REASON_RULE)
	end
end
-- 效果③的触发条件：连锁中有效果为速攻魔法卡的发动的场合（re为发动效果且类型为速攻魔法）。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_QUICKPLAY)
end
-- 过滤条件：卡是「绚岚」字段的永续陷阱卡，且不是禁止状态、己方魔陷区不存在同名卡重复。
function s.pfilter(c,tp)
	return c:IsAllTypes(TYPE_CONTINUOUS+TYPE_TRAP) and c:IsSetCard(0x1d1)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果③发动判定：己方魔陷区有空格，并且卡组·墓地存在符合条件的「绚岚」永续陷阱卡。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方魔法陷阱区是否有可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组·墓地是否存在至少1张符合条件的「绚岚」永续陷阱卡。
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end
-- 效果③处理：从自己卡组·墓地选择1张「绚岚」永续陷阱卡表侧表示放置到己方魔陷区；墓地选择同样受王家长眠之谷影响。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若己方魔陷区已无空位，则直接终止本效果的后续操作。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 弹出卡片选择提示“请选择要放置到场上的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组·墓地选择1张符合条件的「绚岚」永续陷阱卡（过滤时使用NecroValleyFilter避免王家长眠之谷影响）。
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	-- 将选择的「绚岚」永续陷阱卡以表侧表示放置到己方魔法陷阱区。
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
